import 'dart:math';

import 'package:skribbl_client/models/models.dart';

import 'package:get/get.dart';

import 'jiggle_avatar.dart';

class AvatarEditorController extends GetxController {
  AvatarEditorController() {
    var rd = Random();
    color = rd.nextInt(GifManager.inst.colorLength).obs;
    eyes = rd.nextInt(GifManager.inst.eyesLength).obs;
    mouth = rd.nextInt(GifManager.inst.mouthLength).obs;

    MePlayer.init(AvatarModel.init(color.value, eyes.value, mouth.value).builder.init());
  }

  late final RxInt color;
  late final RxInt eyes;
  late final RxInt mouth;

  @override
  void onClose() {
    jiggleEyes.dispose();
    jiggleMouth.dispose();

    super.onClose();
  }

  final JiggleController jiggleEyes = JiggleController();
  final JiggleController jiggleMouth = JiggleController();

  void onPreviousEyes() {
    if (eyes.value == 0) {
      eyes.value = GifManager.inst.eyesLength - 1;
    } else {
      eyes - 1;
    }
    MePlayer.inst.avatar.model.eyes = GifManager.inst.eyes(eyes.value);

    jiggleEyes.jiggle();
  }

  void onNextEyes() {
    if (eyes.value == GifManager.inst.eyesLength - 1) {
      eyes.value = 0;
    } else {
      eyes + 1;
    }
    MePlayer.inst.avatar.model.eyes = GifManager.inst.eyes(eyes.value);

    jiggleEyes.jiggle();
  }

  void onPreviousMouth() {
    if (mouth.value == 0) {
      mouth.value = GifManager.inst.mouthLength - 1;
    } else {
      mouth - 1;
    }
    MePlayer.inst.avatar.model.mouth = GifManager.inst.mouth(mouth.value);

    jiggleMouth.jiggle();
  }

  void onNextMouth() {
    if (mouth.value == GifManager.inst.mouthLength - 1) {
      mouth.value = 0;
    } else {
      mouth + 1;
    }
    MePlayer.inst.avatar.model.mouth = GifManager.inst.mouth(mouth.value);

    jiggleMouth.jiggle();
  }

  void onPreviousColor() {
    if (color.value == 0) {
      color.value = GifManager.inst.colorLength - 1;
    } else {
      color - 1;
    }
    MePlayer.inst.avatar.model.color = GifManager.inst.color(color.value);
  }

  void onNextColor() {
    if (color.value == GifManager.inst.colorLength - 1) {
      color.value = 0;
    } else {
      color + 1;
    }
    MePlayer.inst.avatar.model.color = GifManager.inst.color(color.value);
  }

  void randomize() {
    var rd = Random();
    color.value = rd.nextInt(GifManager.inst.colorLength);
    eyes.value = rd.nextInt(GifManager.inst.eyesLength);
    mouth.value = rd.nextInt(GifManager.inst.mouthLength);
    MePlayer.inst.avatar.model = AvatarModel.init(color.value, eyes.value, mouth.value);
  }
}
