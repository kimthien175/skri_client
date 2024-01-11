import 'dart:math';

import 'package:cd_mobile/models/game_play/player.dart';
import 'package:cd_mobile/models/gif/avatar/model.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:get/get.dart';

/// MePlayer is created at here
class AvatarEditorController extends GetxController {
  AvatarEditorController() {
    var rd = Random();
    color = rd.nextInt(GifManager.inst.colorLength);
    eyes = rd.nextInt(GifManager.inst.eyesLength);
    mouth = rd.nextInt(GifManager.inst.mouthLength);

    MePlayer.init(AvatarModel.init(color, eyes, mouth).builder.init());
  }

  late int color;
  late int eyes;
  late int mouth;

  void onPreviousEyes() {
    if (eyes == 0) {
      eyes = GifManager.inst.eyesLength - 1;
    } else {
      eyes = eyes - 1;
    }
    MePlayer.inst.avatar.model.eyes = GifManager.inst.eyes(eyes);
  }

  void onNextEyes() {
    if (eyes == GifManager.inst.eyesLength - 1) {
      eyes = 0;
    } else {
      eyes++;
    }
    MePlayer.inst.avatar.model.eyes = GifManager.inst.eyes(eyes);
  }

  void onPreviousMouth() {
    if (mouth == 0) {
      mouth = GifManager.inst.mouthLength - 1;
    } else {
      mouth = mouth - 1;
    }
    MePlayer.inst.avatar.model.mouth = GifManager.inst.mouth(mouth);
  }

  void onNextMouth() {
    if (mouth == GifManager.inst.mouthLength - 1) {
      mouth = 0;
    } else {
      mouth++;
    }
    MePlayer.inst.avatar.model.mouth = GifManager.inst.mouth(mouth);
  }

  void onPreviousColor() {
    if (color == 0) {
      color = GifManager.inst.colorLength - 1;
    } else {
      color = color - 1;
    }
    MePlayer.inst.avatar.model.color = GifManager.inst.color(color);
  }

  void onNextColor() {
    if (color == GifManager.inst.colorLength - 1) {
      color = 0;
    } else {
      color++;
    }
    MePlayer.inst.avatar.model.color = GifManager.inst.color(color);
  }

  void randomize() {
    var rd = Random();
    color = rd.nextInt(GifManager.inst.colorLength);
    eyes = rd.nextInt(GifManager.inst.eyesLength);
    mouth = rd.nextInt(GifManager.inst.mouthLength);
    MePlayer.inst.avatar.model = AvatarModel.init(color, eyes, mouth);
  }
}
