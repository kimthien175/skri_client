import 'dart:async';
import 'package:cd_mobile/models/gif.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/models/shadow_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:visibility_detector/visibility_detector.dart';

// ignore: must_be_immutable
class Avatar extends StatelessWidget {
  Avatar(int color, int eyes, int mouth, {super.key}) {
    var gif = GifManager.inst;
    colorModel = gif.color(color);
    eyesModel = gif.eyes(eyes);
    mouthModel = gif.mouth(mouth);

    controller = AvatarController(colorModel.frames.length, colorModel.frames[0].duration);
  }

  late GifModel colorModel;

  late GifModel eyesModel;

  late GifModel mouthModel;

  //#region Crown
  // Gif get crown => GifManager.inst.misc('crown');
  // double get crownTopOffset => -crown.height / 2 + 2;
  // static double _crownLeftOffset = -3;
  // Avatar withCrown() {
  //   widgets.add(Positioned(top: 0, left: crownLeftOffset, child: crown));
  //   _height = _height - crownTopOffset;
  //   return this;
  // }
  //#endregion

  //#region Shadow
  // Avatar withShadow({ShadowInfo info = const ShadowInfo()}) {
  //   widgets.insert(0, AvatarShadow(this, info: info));
  //   return this;
  // }
  //#endregion

  late final AvatarController controller;
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: Key(hashCode.toString()),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction == 0) {
            controller.pauseTimer();
          } else {
            controller.startTimer();
          }
        },
        child: Obx(() => CustomPaint(
            painter: _CustomPainter(this, controller.currentFrameIndex.value, Paint()),
            child: SizedBox(height: colorModel.height, width: colorModel.width))));
  }
}

class _CustomPainter extends CustomPainter {
  _CustomPainter(this.avatar, this.frameIndex, this._paint);

  final Avatar avatar;
  final int frameIndex;

  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    avatar.colorModel.getCustomPainter(frameIndex, _paint).paint(canvas, size);
    avatar.eyesModel.getCustomPainter(frameIndex, _paint).paint(canvas, size);
    avatar.mouthModel.getCustomPainter(frameIndex, _paint).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Assume color, eyes, mouth have the same frame time for each frame and frame count as well, for better performance
class AvatarController extends GetxController {
  AvatarController(this.frameCount, this.frameTime);

  late Timer _timer;
  RxInt currentFrameIndex = 0.obs;

  late final int frameCount;
  late final Duration frameTime;

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

  void nextColor() {}
  void previousColor() {}

  void nextEyes() {}
  void previousEyes() {}

  void nextMouth() {}
  void previousMouth() {}
}

// ignore: must_be_immutable
class AvatarWithShadow extends Avatar {
  AvatarWithShadow(super.color, super.eyes, super.mouth,
      {super.key, this.shadowInfo = const ShadowInfo()});

  final ShadowInfo shadowInfo;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: Key(hashCode.toString()),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction == 0) {
            controller.pauseTimer();
          } else {
            controller.startTimer();
          }
        },
        child: Obx(() => Stack(clipBehavior: Clip.none, children: [
              Transform.translate(
                  offset: Offset(shadowInfo.offsetLeft, shadowInfo.offsetTop),
                  child: Opacity(
                      opacity: shadowInfo.opacity,
                      child: CustomPaint(
                          painter: _CustomPainter(
                              this,
                              controller.currentFrameIndex.value,
                              Paint()
                                ..colorFilter =
                                    const ColorFilter.mode(Colors.black, BlendMode.srcATop)),
                          child: SizedBox(height: colorModel.height, width: colorModel.width)))),
              CustomPaint(
                  painter: _CustomPainter(this, controller.currentFrameIndex.value, Paint()))
            ])));
  }
}
