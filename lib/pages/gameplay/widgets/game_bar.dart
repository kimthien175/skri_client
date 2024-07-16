import 'dart:async';

import 'package:skribbl_client/models/gif_manager.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/styles.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';

// TODO: SYNC TO GAME
class GameBar extends StatelessWidget {
  const GameBar({super.key});
  static const double height = 48.0;
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.centerLeft, clipBehavior: Clip.none, children: [
      Container(
          constraints: const BoxConstraints.expand(height: height),
          decoration: BoxDecoration(
              color: GameplayStyles.colorPlayerBGBase, borderRadius: GlobalStyles.borderRadius),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const SizedBox(width: PlayerCard.width),
            Text(
              'WAITING'.tr,
              style: const TextStyle(
                  fontFamily: 'Inconsolata', fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(width: GameChat.width)
          ])),
      const Positioned(top: -10, left: -8, child: GameClock()),
      Positioned(
          left: 60,
          top: 13,
          child:
              //Obx(() =>
              Text(
                  "gamebar_round_display".trParams({
                    "currentRound": '1', //Game.inst.currentRound.value.toString(),
                    "rounds": '3' //Game.inst.rounds.value.toString()
                  }),
                  style: const TextStyle(
                      fontFamily: 'Nunito-var',
                      fontSize: 19.6,
                      fontVariations: [FontVariation.weight(720)]))),
      Positioned(
          right: 3,
          child: AnimatedButton(
              decorators: [
                AnimatedButtonOpacityDecorator(minOpacity: 0.9),
                AnimatedButtonScaleDecorator.max(scale: 1.1),
                AnimatedButtonTooltipDecorator(tooltip: 'Settings', position: TooltipPositionLeft())
              ],
              child: GifManager.inst
                  .misc('settings')
                  .builder
                  .initWithShadow(filterQuality: FilterQuality.none, height: 42, width: 42)))
    ]);
  }
}

/// Count down, start animation when time smaller than 10
class GameClock extends GetView<GameClockController> {
  const GameClock({super.key});

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
        turns: controller.rotateAnimation,
        child: ScaleTransition(
            scale: controller.scaleAnimation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GifManager.inst.misc('clock').builder.initWithShadow(width: 64, height: 64),
                Positioned(
                    top: 20,
                    child: Obx(() => Text(
                        controller.remainingTime.value
                            .toString(), //Game.inst.remainingTime.seconds.value.toString(),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))))
              ],
            )));
  }
}

class GameClockController extends GetxController with GetSingleTickerProviderStateMixin {
  @override
  onInit() {
    super.onInit();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
      reverseDuration: const Duration(milliseconds: 250),
    );

    curvedAnimation = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    scaleAnimation = curvedAnimation.drive(Tween<double>(begin: 1.0, end: 1.4));

    rotateTween = Tween<double>(begin: 0, end: turnsEnd);
    rotateAnimation = curvedAnimation.drive(rotateTween);

    timer = Timer.periodic(const Duration(seconds: 1), decreaseSeconds);
  }

  late final Timer timer;

  Future<void> decreaseSeconds(Timer timer) async {
    if (remainingTime.value == 0) {
      timer.cancel();
      return;
    }

    remainingTime--;
    if (remainingTime.value >= 10 // TODO: || Game.inst.allCorrectBeforeTimeEnd
        ) return;

    await controller.forward();
    await controller.reverse();

    // reverse rotate direction
    rotateTween.end = turnsEnd;
  }

  var remainingTime = 20.obs;

  late final AnimationController controller;
  late final CurvedAnimation curvedAnimation;

  late final Animation<double> scaleAnimation;

  late final Animation<double> rotateAnimation;
  late final Tween<double> rotateTween;
  double get turnsEnd => (remainingTime.value % 2 == 0) ? 0.125 : -0.125;

  @override
  void onClose() {
    curvedAnimation.dispose();
    controller.dispose();

    super.onClose();
  }
}
