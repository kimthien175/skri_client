import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/sound.dart';

import '../../../../models/models.dart';

/// Count down, start animation when time smaller than 10
class GameClock extends GetView<GameClockController> {
  const GameClock({super.key});

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: controller._rotateAnimation,
      child: ScaleTransition(
        scale: controller._scaleAnimation,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GifManager.inst.misc('clock').builder.initWithShadow().fit(width: 64, height: 64),
            Positioned(
              top: 20,
              child: GetBuilder<GameClockController>(
                builder: (c) => Text(
                  c.displayedSeconds.toString(),
                  style: const TextStyle(fontSize: 22, fontVariations: [FontVariation.weight(800)]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameClockController extends GetxController with GetSingleTickerProviderStateMixin {
  @override
  onInit() {
    super.onInit();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _curvedAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _scaleAnimation = _curvedAnimation.drive(Tween<double>(begin: 1.0, end: 1.4));

    _rotateTween = Tween<double>(begin: 0, end: turnsEnd);
    _rotateAnimation = _curvedAnimation.drive(_rotateTween);
  }

  void countdown(Duration duration, {void Function()? onEnd}) {
    _remainingTimeSinceStart = duration;
    _preciseTimer = Timer(
      duration,
      onEnd != null
          ? () {
              cancel();
              onEnd();
            }
          : cancel,
    );

    _stopWatch
      ..reset()
      ..start();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), refreshClock);

    // re render
    refreshClock(_clockTimer!);
  }

  void cancel() {
    _preciseTimer?.cancel();
    _stopWatch
      ..stop()
      ..reset();
    _clockTimer?.cancel();
    _remainingTimeSinceStart = Duration.zero;
    update();
  }

  Duration _remainingTimeSinceStart = Duration.zero;

  /// execute onEnd
  Timer? _preciseTimer;

  /// update seconds
  Timer? _clockTimer;

  /// to get the exact elapsed time while `Timer` can't help with that
  final Stopwatch _stopWatch = Stopwatch();
  int get displayedSeconds => (_remainingTimeSinceStart - _stopWatch.elapsed).inSeconds;

  Future<void> refreshClock(Timer timer) async {
    update();

    if (displayedSeconds >= 10) return;

    Sound.inst.play(Sound.inst.tick);

    await _controller.forward();
    await _controller.reverse();

    // reverse rotate direction
    _rotateTween.end = turnsEnd;
  }

  late final AnimationController _controller;
  late final CurvedAnimation _curvedAnimation;

  late final Animation<double> _scaleAnimation;

  late final Animation<double> _rotateAnimation;
  late final Tween<double> _rotateTween;
  double get turnsEnd => (displayedSeconds % 2 == 0) ? 0.125 : -0.125;

  @override
  void onClose() {
    cancel();
    _curvedAnimation.dispose();
    _controller.dispose();

    super.onClose();
  }
}
