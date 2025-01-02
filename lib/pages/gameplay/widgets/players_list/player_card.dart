import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayerController extends GetxController with GetTickerProviderStateMixin {
  late final AnimationController animController =
      AnimationController(duration: AnimatedButton.duration, vsync: this);
  late final Animation<double> animation =
      CurvedAnimation(parent: animController, curve: Curves.linear)
          .drive(Tween<double>(begin: 1.0, end: 1.1));

  late final GlobalKey anchorKey;
  late final GameTooltip tooltip;
  RxString tooltipContent = ''.obs;

  late final AnimationController tooltipController =
      AnimationController(duration: AnimatedButton.duration, vsync: this);

  @override
  void onInit() {
    super.onInit();
    anchorKey = GlobalKey();
    tooltip = GameTooltip(
        anchorKey: anchorKey,
        position: GameTooltipPosition.centerRight(),
        childBuilder: () => Obx(() => Text(tooltipContent.value)),
        controller: tooltipController);
  }

  @override
  void onClose() {
    animController.dispose();
    tooltipController.dispose();
    super.onClose();
  }

  void showMessage(String text) {
    tooltipContent.value = text;
    tooltip
        .show()
        .then((_) => Future.delayed(const Duration(seconds: 2)))
        .then((_) => tooltip.hide());
  }
}

class PlayerCard extends StatelessWidget {
  const PlayerCard({required this.info, required this.index, super.key});
  final Player info;
  final int index;

  static const double width = 200.0;

  // TODO: DIALOG CONTENT DIFFERENT DEPENDS ON STATE
  void showInfo() {
    GameDialog(
        exitTap: true,
        title: Builder(builder: (_) => Text(info.nameForCard)),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            info.avatarModel.builder.init().fit(width: 150),
            Column(
              children: [
                Text('invite_your_friends'.tr, style: const TextStyle(
                    fontSize: 19.5,
                    //    color: Colors.white,
                    fontVariations: [FontVariation.weight(500)])),
                const SizedBox(height: 7.5),
                HoverButton(
                    // TODO: WHEN GAME LOGIC DONE, UNCOMMENT THIS
                    //onTap: Game.inst.copyLink,
                    height: 34.5,
                    width: 200,
                    child: Text(
                      'click_to_copy_invite'.tr,
                      style: const TextStyle(fontSize: 15),
                    ))
              ],
            )
          ],
        )).showOnce();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
        var inst = Game.inst;
        var lastIndex = inst.playersByList.length - 1;
        var controller = Get.find<PlayerController>(tag: info.id);
        return GestureDetector(
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
                              ? (index == lastIndex
                                  ? BorderRadius.circular(3)
                                  : const BorderRadiusDirectional.vertical(top: Radius.circular(3)))
                              : (index == lastIndex
                                  ? const BorderRadiusDirectional.vertical(
                                      bottom: Radius.circular(3))
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
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontVariations: [FontVariation.weight(800)],
                                  color:
                                      //info.id == MePlayer.inst.id
                                      //     ? GameplayStyles.colorPlayerMe
                                      //     :
                                      Colors.black,
                                  height: 1.1)),
                          const Text('0 points',
                              style: TextStyle(
                                  fontSize: 12.6,
                                  height: 1,
                                  fontVariations: [FontVariation.weight(600)]))
                        ],
                      )),
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
                ])));
      });
}
