import 'package:skribbl_client/models/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class AvatarBuilder extends ControlledGifBuilder<AvatarModel> {
  AvatarBuilder(super.model, {super.key});

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
        painter: AvatarCustomPainter(
            model, ControlledGifBuilder.controller.currentFrameIndex.value, Paint()),
        size: Size(model.width, model.height)));
    return this;
  }

  @override
  AvatarBuilder initWithShadow(
      {Color? color,
      ShadowInfo info = const ShadowInfo(),
      double? height,
      double? width,
      FilterQuality filterQuality = FilterQuality.low}) {
    var size = Size(width ?? model.width, height ?? model.height);

    widget = Obx(() => Stack(clipBehavior: Clip.none, children: [
          Transform.translate(
              offset: info.offset,
              child: Opacity(
                  opacity: info.opacity,
                  child: CustomPaint(
                      painter: AvatarCustomPainter(
                          model,
                          ControlledGifBuilder.controller.currentFrameIndex.value,
                          Paint()
                            ..colorFilter =
                                const ColorFilter.mode(Colors.black, BlendMode.srcATop)),
                      size: size))),
          CustomPaint(
              painter: AvatarCustomPainter(
                  model, ControlledGifBuilder.controller.currentFrameIndex.value, Paint()),
              size: size)
        ]));
    return this;
  }

  @override
  AvatarBuilder doFreezeSize() {
    return this;
  }
}
