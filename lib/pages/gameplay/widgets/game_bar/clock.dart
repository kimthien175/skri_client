import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/sound.dart';

import '../../../../models/models.dart';

/// Count down, start animation when time smaller than 10
class GameClock extends GetView<GameClockController> {
  const GameClock({super.key});

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
        turns: controller.rotateAnimation,
        child: ScaleTransition(
            scale: controller.scaleAnimation,
            child: Stack(alignment: Alignment.center, children: [
              GifManager.inst.misc('clock').builder.initWithShadow().fit(width: 64, height: 64),
              Positioned(
                  top: 20,
                  child: GetBuilder<GameClockController>(
                      builder: (c) => Text(c.displayedSeconds.toString(),
                          style: const TextStyle(
                              fontSize: 22, fontVariations: [FontVariation.weight(800)]))))
            ])));
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
  }

  void start(Duration remainingTime, {void Function()? onEnd}) {
    remainingTimeSinceStart = remainingTime;
    preciseTimer = Timer(
        remainingTime,
        onEnd != null
            ? () {
                cancel();
                onEnd();
              }
            : cancel);

    stopWatch
      ..reset()
      ..start();
    clockTimer = Timer.periodic(const Duration(seconds: 1), refreshClock);

    // re render
    refreshClock(clockTimer!);
  }

  void cancel() {
    preciseTimer?.cancel();
    stopWatch.reset();
    clockTimer?.cancel();
    remainingTimeSinceStart = Duration.zero;
    update();
  }

  Duration remainingTimeSinceStart = Duration.zero;
  Timer? preciseTimer;
  Timer? clockTimer;
  Stopwatch stopWatch = Stopwatch();

  int get displayedSeconds => (remainingTimeSinceStart - stopWatch.elapsed).inSeconds;

  Future<void> refreshClock(Timer timer) async {
    update();

    if (displayedSeconds >= 10) return;

    Sound.inst.play(Sound.inst.tick);

    await controller.forward();
    await controller.reverse();

    // reverse rotate direction
    rotateTween.end = turnsEnd;
  }

  late final AnimationController controller;
  late final CurvedAnimation curvedAnimation;

  late final Animation<double> scaleAnimation;

  late final Animation<double> rotateAnimation;
  late final Tween<double> rotateTween;
  double get turnsEnd => (displayedSeconds % 2 == 0) ? 0.125 : -0.125;

  @override
  void onClose() {
    cancel();
    curvedAnimation.dispose();
    controller.dispose();

    super.onClose();
  }
}
