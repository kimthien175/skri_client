library chid_gif;

export 'custom_painter.dart';

import 'package:skribbl_client/models/models.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChildGifModel extends SingleGifModel<ChildGifModel> {
  ChildGifModel(this._rect, List<ui.FrameInfo> frames, {int? index, String? name})
      : super(frames, _rect.width, _rect.height, index: index, name: name);

  final Rect _rect;
  Rect get rect => _rect;

  @override
  CustomPainter getCustomPainter(int frameIndex, ui.Paint paint, {Offset offset = Offset.zero}) =>
      ChildGifCustomPainter(rect, frames[frameIndex].image, paint);

  @override
  ChildGifBuilder get builder => ChildGifBuilder(this);
}

// ignore: must_be_immutable
class ChildGifBuilder extends ControlledGifBuilder<ChildGifModel> {
  ChildGifBuilder(super.model, {super.key});

  @override
  GifBuilder<GifModel> doScale(double ratio) {
    widget = Transform.scale(scale: ratio, child: widget);
    return this;
  }

  @override
  GifBuilder<GifModel> init({Color? color, double? width, double? height}) {
    widget = Obx(() => CustomPaint(
        painter: ChildGifCustomPainter(model.rect,
            model.frames[ControlledGifBuilder.controller.currentFrameIndex.value].image, Paint()),
        size: Size(width ?? model.width,
            height ?? model.height) // to make gif animated, have to put SizedBox into this
        ));
    return this;
  }

  @override
  GifBuilder<GifModel> initWithShadow(
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
                      painter: model.getCustomPainter(
                        ControlledGifBuilder.controller.currentFrameIndex.value,
                        Paint()
                          ..colorFilter = const ColorFilter.mode(Colors.black, BlendMode.srcATop),
                      ),
                      size: size))),
          CustomPaint(
              painter: ChildGifCustomPainter(
                  model.rect,
                  model.frames[ControlledGifBuilder.controller.currentFrameIndex.value].image,
                  Paint()),
              size: size)
        ]));
    return this;
  }
}
