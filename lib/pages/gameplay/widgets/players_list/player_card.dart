import 'package:cd_mobile/models/game/player.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/pages/gameplay/widgets/players_list/players_list.dart';
import 'package:cd_mobile/widgets/dialog.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:cd_mobile/widgets/animated_button/builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayerController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController animController = AnimationController(
      duration: AnimatedButtonBuilder.duration,
      vsync: this,
      lowerBound: 1 / PlayerCard.avatarMaxScale);
  late final Animation<double> animation =
      CurvedAnimation(parent: animController, curve: Curves.linear);

  @override
  void onClose() {
    animController.dispose();
    super.onClose();
  }
}

class PlayerCard extends StatelessWidget {
  const PlayerCard({required this.info, required this.index, super.key});
  final Player info;
  final int index;

  static const double width = 200.0;

  static const double avatarMaxScale = 1.2;

  void showInfo() {
    GameDialog(title: info.nameForCard).show();
  }

  @override
  Widget build(BuildContext context) {
    var lastIndex = Get.find<PlayersListController>().players.length - 1;
    var controller = Get.find<PlayerController>(tag: index.toString());
    return GestureDetector(
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
                              : const BorderRadiusDirectional.vertical(
                                  top: Radius.circular(3)))
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
                              fontWeight: FontWeight.w800,
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
                              fontWeight: FontWeight.w600))
                    ],
                  )),
              Positioned(
                  top: -1 - 48 * (avatarMaxScale - 1) / 2,
                  right: -48 * (avatarMaxScale - 1) / 2,
                  child: ScaleTransition(
                      scale: controller.animation,
                      child: info.avatar.doFitSize(
                          height: 48 * avatarMaxScale,
                          width: 48 * avatarMaxScale))),
              Positioned(
                  top: 5,
                  left: 6,
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                        fontSize: 15.4, fontWeight: FontWeight.w700),
                  )),
              if (info.isOwner == true)
                Positioned(
                    bottom: 0,
                    left: 4,
                    child: Opacity(
                        opacity: 0.7,
                        child: GifManager.inst.misc('owner').builder.init()))
            ])));
  }
}
