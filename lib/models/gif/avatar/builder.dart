import 'package:cd_mobile/models/gif/avatar/controller.dart';
import 'package:cd_mobile/models/gif/avatar/custom_painter.dart';
import 'package:cd_mobile/models/gif/avatar/model.dart';
import 'package:cd_mobile/models/gif/gif.dart';

import 'package:cd_mobile/models/shadow_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class AvatarBuilder extends GifBuilder<AvatarModel> {
  AvatarBuilder(super.model, {super.key}) {
    var standardFrames = model.color.frames;
    controller ??= Get.put(AvatarController(standardFrames.length, standardFrames[0].duration));
  }

  static AvatarController? controller;

  @override
  AvatarBuilder doFitSize({double? height, double? width}) {
    widget = SizedBox(height: height, width: width, child: FittedBox(child: widget));
    return this;
  }

  @override
  AvatarBuilder doScale(double ratio) {
    widget = Transform.scale(scale: ratio, child: widget);
    return this;
  }

  @override
  AvatarBuilder init({Color? color}) {
    widget = Obx(() => CustomPaint(
        painter: AvatarCustomPainter(model, controller!.currentFrameIndex.value, Paint()),
        child: SizedBox(height: model.height, width: model.width)));
    return this;
  }

  @override
  AvatarBuilder initShadowedOrigin({Color? color, ShadowInfo info = const ShadowInfo()}) {
    widget = Obx(() => Stack(clipBehavior: Clip.none, children: [
          Transform.translate(
              offset: Offset(info.offsetLeft, info.offsetTop),
              child: Opacity(
                  opacity: info.opacity,
                  child: CustomPaint(
                      painter: AvatarCustomPainter(
                          model,
                          controller!.currentFrameIndex.value,
                          Paint()
                            ..colorFilter =
                                const ColorFilter.mode(Colors.black, BlendMode.srcATop)),
                      child: SizedBox(height: model.height, width: model.width)))),
          CustomPaint(
              painter: AvatarCustomPainter(model, controller!.currentFrameIndex.value, Paint()))
        ]));
    return this;
  }

  @override
  AvatarBuilder doFreezeSize() {
    return this;
  }
}
