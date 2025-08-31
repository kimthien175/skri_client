import 'dart:async';

import 'package:get/get.dart';

class GifController extends GetxController {
  GifController() {
    timer = Timer.periodic(frameTime, switchFrame);
  }
  static const Duration frameTime = Duration(milliseconds: 200);
  static const int frameCount = 2;

  RxInt currentFrameIndex = 0.obs;

  late Timer timer;

  void switchFrame(Timer timer) {
    if (currentFrameIndex.value == frameCount - 1) {
      currentFrameIndex.value = 0;
    } else {
      currentFrameIndex++;
    }
  }

  @override
  void onClose() {
    timer.cancel();
    super.onClose();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
