import 'package:skribbl_client/models/game/state/draw/draw.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/pages/gameplay/widgets/players_list/players_list.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'player_card/info.dart';

class PlayerController extends GetxController with GetTickerProviderStateMixin {
  PlayerController({required this.id});
  final String id;
  late final AnimationController animController =
      AnimationController(duration: AnimatedButton.duration, vsync: this);
  late final Animation<double> animation =
      CurvedAnimation(parent: animController, curve: Curves.linear)
          .drive(Tween<double>(begin: 1.0, end: 1.1));

  late final GlobalKey anchorKey;
  late final NewGameTooltipController tooltip;
  RxString tooltipContent = ''.obs;

  late final AnimationController tooltipController =
      AnimationController(duration: AnimatedButton.duration, vsync: this);

  @override
  void onInit() {
    super.onInit();
    anchorKey = GlobalKey();
    tooltip = NewGameTooltipController(
        //anchorKey: anchorKey,
        position: const NewGameTooltipPosition.centerRight(),
        tooltip: Obx(() => Text(tooltipContent.value)),
        controller: tooltipController);
  }

  @override
  void onClose() {
    animController.dispose();
    tooltipController.dispose();
    Get.delete<OverlayController>(tag: tooltip.tag);
    OverlayController.deleteCache('card_info_$id');
    super.onClose();
  }

  Future<bool> showMessage(String text) async {
    tooltipContent.value = text;
    if (tooltip.isShowing) await tooltip.hideInstancely();

    await tooltip.show();
    await Future.delayed(const Duration(seconds: 2));
    return tooltip.hide();
  }
}

class PlayerCard extends StatelessWidget {
  const PlayerCard({required this.info, required this.index, super.key});
  final Player info;
  final int index;

  static const double width = 200.0;

  void showInfo() {
    PlayerInfoDialog.factory(info).show();
  }

  bool get isLast => Get.find<PlayersListController>().list.length - 1 == index;

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<PlayerController>(tag: info.id);

    return controller.tooltip.attach(Obx(() {
      var inst = Game.inst;

      var state = inst.state.value;
      return controller.tooltip.attach(GestureDetector(
          key: controller.anchorKey,
          onTap: showInfo,
          child: MouseRegion(
              onEnter: (_) {
                controller.animController.forward();
              },
              onExit: (_) {
                controller.animController.reverse();
              },
              cursor: SystemMouseCursors.click,
              child: Stack(clipBehavior: Clip.none, children: [
                Container(
                    decoration: BoxDecoration(
                        borderRadius: index == 0
                            ? (isLast
                                ? BorderRadius.circular(3)
                                : const BorderRadiusDirectional.vertical(top: Radius.circular(3)))
                            : (isLast
                                ? const BorderRadiusDirectional.vertical(bottom: Radius.circular(3))
                                : BorderRadius.zero),
                        color: index % 2 == 0
                            ? GameplayStyles.colorPlayerBGBase
                            : GameplayStyles.colorPlayerBGBase_2),
                    height: 48,
                    width: width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(info.nameForCard,
                            style: TextStyle(
                                fontSize: 14,
                                fontVariations: [FontVariation.weight(800)],
                                color: info.id == MePlayer.inst.id
                                    ? GameplayStyles.colorPlayerMe
                                    : Colors.black,
                                height: 1.1)),
                        Text('${info.score.toString()} ${'points'.tr}',
                            style: TextStyle(
                                fontSize: 12.6,
                                height: 1,
                                fontVariations: [FontVariation.weight(600)]))
                      ],
                    )),
                if (state is DrawStateMixin && state.performerId == info.id)
                  Positioned(
                      bottom: 0,
                      right: 38,
                      child: GifManager.inst.misc('pen').builder.init().fit(width: 32)),
                Positioned(
                    top: -1,
                    right: 0,
                    child: ScaleTransition(
                        scale: controller.animation,
                        child: info.avatarModel.builder.init().fit(width: 48))),
                Positioned(
                    top: 5,
                    left: 6,
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(
                          fontSize: 15.4, fontVariations: [FontVariation.weight(700)]),
                    )),
                if (inst is PrivateGame && info.id == inst.hostPlayerId.value)
                  Positioned(
                      bottom: 0,
                      left: 4,
                      child: Opacity(
                          opacity: 0.7, child: GifManager.inst.misc('owner').builder.init()))
              ]))));
    }));
  }
}
