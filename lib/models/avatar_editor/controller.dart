import 'dart:math';

import 'package:cd_mobile/models/gif_manager.dart';
import 'package:get/get.dart';

class AvatarEditorController extends GetxController {
  AvatarEditorController() {
    var rd = Random();
    color = rd.nextInt(GifManager.inst.colorLength).obs;
    eyes = rd.nextInt(GifManager.inst.eyesLength).obs;
    mouth = rd.nextInt(GifManager.inst.mouthLength).obs;
  }

  late RxInt color;
  late RxInt eyes;
  late RxInt mouth;

  void onPreviousEyes() {
    if (eyes.value == 0) {
      eyes.value = GifManager.inst.eyesLength - 1;
    } else {
      eyes.value = eyes.value - 1;
    }
  }

  void onNextEyes() {
    if (eyes.value == GifManager.inst.eyesLength - 1) {
      eyes.value = 0;
    } else {
      eyes++;
    }
  }

  void onPreviousMouth() {
    if (mouth.value == 0) {
      mouth.value = GifManager.inst.mouthLength - 1;
    } else {
      mouth.value = mouth.value - 1;
    }
  }

  void onNextMouth() {
    if (mouth.value == GifManager.inst.mouthLength - 1) {
      mouth.value = 0;
    } else {
      mouth++;
    }
  }

  void onPreviousColor() {
    if (color.value == 0) {
      color.value = GifManager.inst.colorLength - 1;
    } else {
      color.value = color.value - 1;
    }
  }

  void onNextColor() {
    if (color.value == GifManager.inst.colorLength - 1) {
      color.value = 0;
    } else {
      color++;
    }
  }

  void randomize() {
    var rd = Random();
    color.value = rd.nextInt(GifManager.inst.colorLength);
    eyes.value = rd.nextInt(GifManager.inst.eyesLength);
    mouth.value = rd.nextInt(GifManager.inst.mouthLength);
  }
}
