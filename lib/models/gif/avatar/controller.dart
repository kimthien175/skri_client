library avatar;

import 'dart:async';

import 'package:get/get.dart';
import 'package:cd_mobile/models/gif/avatar/custom_painter.dart';
import 'package:cd_mobile/models/gif/avatar/model.dart';
import 'package:cd_mobile/models/gif/gif.dart';

import 'package:cd_mobile/models/shadow_info.dart';
import 'package:flutter/material.dart';

part 'builder.dart';

/// Assume color, eyes, mouth have the same frame time for each frame and frame count as well, for better performance
class AvatarController extends GetxController {
  static AvatarController? _inst;
  static bool get isEmpty => _inst == null;
  static AvatarController get inst => _inst!;

  AvatarController._internal(this.frameCount, this.frameTime) {
    _timer = Timer.periodic(frameTime, switchFrame);
  }

  late Timer _timer;
  RxInt currentFrameIndex = 0.obs;

  final int frameCount;
  final Duration frameTime;

  void switchFrame(Timer _) {
    if (currentFrameIndex.value == frameCount - 1) {
      currentFrameIndex.value = 0;
    } else {
      currentFrameIndex++;
    }
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }
}
