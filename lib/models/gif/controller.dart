import 'dart:async';

import 'package:get/get.dart';

class ChildGifController extends GetxController {
  ChildGifController(this.frameCount, this.duration){
    timer = Timer(duration, switchFrame);
  }

  RxInt currentFrameIndex = 0.obs;

  final int frameCount;
  final Duration duration;
  late Timer timer;

  switchFrame() {
    currentFrameIndex++;
    if (currentFrameIndex.value == frameCount) {
      currentFrameIndex.value = 0;
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