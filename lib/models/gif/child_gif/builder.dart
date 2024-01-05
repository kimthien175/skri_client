import 'package:cd_mobile/models/gif/builder.dart';
import 'package:cd_mobile/models/gif/child_gif/custom_painter.dart';
import 'package:cd_mobile/models/gif/child_gif/controller.dart';
import 'package:cd_mobile/models/gif/model.dart';
import 'package:cd_mobile/models/shadow_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class ChildGifBuilder extends GifBuilder {
  ChildGifBuilder(GifModel model, {super.key}) : super(model) {
    controller ??= ChildGifController(model.frames.length, model.frames[0].duration);
  }

  static ChildGifController? controller;

  @override
  GifBuilder withFixedSize() => this;

  @override
  GifBuilder withShadow({ShadowInfo info = const ShadowInfo()}) {
    builder = () => Stack(
          clipBehavior: Clip.none,
          children: [
            Opacity(
                opacity: info.opacity,
                child: CustomPaint(
                    painter: model.getCustomPainter(controller!.currentFrameIndex.value, Paint(),
                        offset: Offset(info.offsetLeft, info.offsetTop)))),
            builder()
          ],
        );
    return this;
  }

  @override
  GifBuilderCallback rawWidget(GifModel model) => () => CustomPaint(
        painter: ChildGifCustomPainter(
            model.rect, model.frames[controller!.currentFrameIndex.value].image, Paint()),
        child: SizedBox(
            width: model.rect.width,
            height: model.rect.height), // to make gif animated, have to put SizedBox into this
      );

  @override
  Widget build(BuildContext context) {
    return Obx(() => builder());
  }
}
