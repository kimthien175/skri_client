import 'dart:math';

import 'package:cd_mobile/models/gif/avatar/builder.dart';
import 'package:cd_mobile/models/gif/avatar/model.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:get/get.dart';

class AvatarEditorController extends GetxController {
  AvatarEditorController() {
    var rd = Random();
    color = rd.nextInt(GifManager.inst.colorLength);
    eyes = rd.nextInt(GifManager.inst.eyesLength);
    mouth = rd.nextInt(GifManager.inst.mouthLength);
    avatar = AvatarModel.init(color, eyes, mouth).builder.asOrigin() as AvatarBuilder;
  }

  late int color;
  late int eyes;
  late int mouth;
 late  AvatarBuilder avatar;

  void onPreviousEyes() {
    if (eyes == 0) {
      eyes = GifManager.inst.eyesLength - 1;
    } else {
      eyes = eyes - 1;
    }
    avatar.model.eyes = GifManager.inst.eyes(eyes);
  }

  void onNextEyes() {
    if (eyes == GifManager.inst.eyesLength - 1) {
      eyes = 0;
    } else {
      eyes++;
    }
    avatar.model.eyes = GifManager.inst.eyes(eyes);
  }

  void onPreviousMouth() {
    if (mouth == 0) {
      mouth = GifManager.inst.mouthLength - 1;
    } else {
      mouth = mouth - 1;
    }
    avatar.model.mouth = GifManager.inst.mouth(mouth);
  }

  void onNextMouth() {
    if (mouth == GifManager.inst.mouthLength - 1) {
      mouth = 0;
    } else {
      mouth++;
    }
    avatar.model.mouth = GifManager.inst.mouth(mouth);
  }

  void onPreviousColor() {
    if (color == 0) {
      color = GifManager.inst.colorLength - 1;
    } else {
      color = color - 1;
    }
    avatar.model.color = GifManager.inst.color(color);
  }

  void onNextColor() {
    if (color == GifManager.inst.colorLength - 1) {
      color = 0;
    } else {
      color++;
    }
    avatar.model.color = GifManager.inst.color(color);
  }

  void randomize() {
    var rd = Random();
    color = rd.nextInt(GifManager.inst.colorLength);
    eyes = rd.nextInt(GifManager.inst.eyesLength);
    mouth = rd.nextInt(GifManager.inst.mouthLength);
    avatar.model = AvatarModel.init(color, eyes, mouth);
  }
}
