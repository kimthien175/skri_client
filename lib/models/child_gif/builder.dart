import 'package:cd_mobile/models/gif/builder.dart';
import 'package:cd_mobile/models/child_gif/custom_painter.dart';
import 'package:cd_mobile/models/child_gif/controller.dart';
import 'package:cd_mobile/models/gif/model.dart';
import 'package:cd_mobile/models/shadow_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class ChildGifBuilder extends GifBuilder {
  ChildGifBuilder(super.model, {super.key});

  static ChildGifController? controller;

  @override
  GifBuilder withFixedSize() => this;

  @override
  GifBuilder withShadow({ShadowInfo info = const ShadowInfo()}) {
    // TODO: OPT WITH COMPLETE CUSTOM PAINTER
    var temp = builder;
    builder = Obx(() => Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
                offset: Offset(info.offsetLeft, info.offsetTop),
                child: Opacity(
                    opacity: info.opacity,
                    child: CustomPaint(
                        painter: model.getCustomPainter(
                          controller!.currentFrameIndex.value,
                          Paint()
                            ..colorFilter = const ColorFilter.mode(Colors.black, BlendMode.srcATop),
                        ),
                        size: Size(model.width, model.height)))),
            temp
          ],
        ));
    return this;
  }

  @override
  Widget rawWidget(GifModel model) {
    controller ??= ChildGifController(model.frames.length, model.frames[0].duration);
    return Obx(() => CustomPaint(
          painter: ChildGifCustomPainter(
              model.rect, model.frames[controller!.currentFrameIndex.value].image, Paint()),
          child: SizedBox(
              width: model.rect.width,
              height: model.rect.height), // to make gif animated, have to put SizedBox into this
        ));
  }
}
