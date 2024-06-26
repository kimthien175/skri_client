import 'package:cd_mobile/models/gif/controlled_gif/builder.dart';
import 'package:cd_mobile/models/gif/gif.dart';
import 'package:cd_mobile/models/gif/single_gif.dart';
import 'package:cd_mobile/models/gif/controlled_gif/child_gif/custom_painter.dart';
import 'package:cd_mobile/models/shadow_info.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChildGifModel extends SingleGifModel<ChildGifModel> {
  ChildGifModel(this._rect, List<ui.FrameInfo> frames, {int? index, String? name}) : super(frames, _rect.width, _rect.height, index: index, name: name);

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
  GifBuilder<GifModel> doFitSize({double? height, double? width}) {
    widget = SizedBox(height: height, width: width, child: FittedBox(child: widget));
    return this;
  }

  @override
  GifBuilder<GifModel> doScale(double ratio) {
    widget = Transform.scale(scale: ratio, child: widget);
    return this;
  }

  @override
  GifBuilder<GifModel> init({Color? color}) {
    widget = _origin;
    return this;
  }

  @override
  GifBuilder<GifModel> initShadowedOrigin({Color? color, ShadowInfo info = const ShadowInfo()}) {
    widget = Obx(() => Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
                offset: Offset(info.offsetLeft, info.offsetTop),
                child: Opacity(
                    opacity: info.opacity,
                    child: CustomPaint(
                        painter: model.getCustomPainter(
                          ControlledGifBuilder.controller.currentFrameIndex.value,
                          Paint()
                            ..colorFilter = const ColorFilter.mode(Colors.black, BlendMode.srcATop),
                        ),
                        size: Size(model.width, model.height)))),
            _origin
          ],
        ));
    return this;
  }

  Widget get _origin => Obx(()=>CustomPaint(
        painter: ChildGifCustomPainter(
            model.rect, model.frames[ControlledGifBuilder.controller.currentFrameIndex.value].image, Paint()),
        child: SizedBox(
            width: model.rect.width,
            height: model.rect.height), // to make gif animated, have to put SizedBox into this
      ));

  @override
  GifBuilder<GifModel> doFreezeSize() {
    return this;
  }
}
