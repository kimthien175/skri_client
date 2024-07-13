import 'package:skribbl_client/models/gif/controlled_gif/avatar/custom_painter.dart';
import 'package:skribbl_client/models/gif/controlled_gif/avatar/model.dart';
import 'package:skribbl_client/models/gif/controlled_gif/builder.dart';
import 'package:skribbl_client/models/shadow_info.dart';
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
        child: SizedBox(height: model.height, width: model.width)));
    return this;
  }

  @override
  AvatarBuilder initShadowedOrigin(
      {Color? color,
      ShadowInfo info = const ShadowInfo(),
      FilterQuality filterQuality = FilterQuality.low}) {
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
                      child: SizedBox(height: model.height, width: model.width)))),
          CustomPaint(
              painter: AvatarCustomPainter(
                  model, ControlledGifBuilder.controller.currentFrameIndex.value, Paint()))
        ]));
    return this;
  }

  @override
  AvatarBuilder doFreezeSize() {
    return this;
  }
}
