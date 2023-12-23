import 'dart:async';

import 'package:get/get.dart';

class ChildGifController extends GetxController {
  ChildGifController(this.frameCount, this.duration) {
    timer = Timer(duration, switchFrame);
  }

  RxInt currentFrameIndex = 0.obs;

  final int frameCount;
  final Duration duration;
  late Timer timer;

  switchFrame() {
    if (currentFrameIndex.value == frameCount - 1) {
      currentFrameIndex.value = 0;
    } else {
      currentFrameIndex++;
    }
    timer = Timer(duration, switchFrame);
  }

  //ui.Image get currentFrame => frame[currentFrameIndex.value].image;

  void startTimer() {
    timer = Timer(duration, switchFrame);
  }

  void pauseTimer() {
    timer.cancel();
  }
}
