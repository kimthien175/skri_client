import 'dart:async';

import 'package:get/get.dart';

/// Assume color, eyes, mouth have the same frame time for each frame and frame count as well, for better performance
class AvatarController extends GetxController {
  AvatarController(this.frameCount, this.frameTime) {
    _timer = Timer(frameTime, switchFrame);
  }

  late Timer _timer;
  RxInt currentFrameIndex = 0.obs;

  final int frameCount;
  final Duration frameTime;

  void switchFrame() {
    currentFrameIndex++;
    if (currentFrameIndex.value == frameCount) {
      currentFrameIndex.value = 0;
    }
    _timer = Timer(frameTime, switchFrame);
  }

  void startTimer() {
    _timer = Timer(frameTime, switchFrame);
  }

  void pauseTimer() {
    _timer.cancel();
  }
}