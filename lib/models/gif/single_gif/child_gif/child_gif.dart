import 'package:cd_mobile/models/gif/gif.dart';
import 'package:cd_mobile/models/gif/single_gif/single_gif.dart';
import 'package:cd_mobile/models/gif/single_gif/child_gif/controller.dart';
import 'package:cd_mobile/models/gif/single_gif/child_gif/custom_painter.dart';
import 'package:cd_mobile/models/shadow_info.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChildGifModel extends SingleGifModel {
  ChildGifModel(this._rect, List<ui.FrameInfo> frames) : super(frames, _rect.width, _rect.height);

  final Rect _rect;
  Rect get rect => _rect;

  @override
  ChildGifBuilder get builder => ChildGifBuilder(this);
  
  @override
  CustomPainter getCustomPainter(int frameIndex, ui.Paint paint, {Offset offset = Offset.zero}) =>ChildGifCustomPainter(rect, frames[frameIndex].image, paint);
}

// ignore: must_be_immutable
class ChildGifBuilder extends GifBuilder<ChildGifModel> {
  ChildGifBuilder(super.model, {super.key}) {
    controller ??= ChildGifController(model.frames.length, model.frames[0].duration);
  }

  static ChildGifController? controller;

  @override
  ChildGifBuilder withFixedSize() => throw UnimplementedError('ChildGif have fixed size already');

  @override
  ChildGifBuilder withShadow({ShadowInfo info = const ShadowInfo()}) {
    // TODO: OPT LATE WITH COMPLETE CUSTOM PAINTER, ONLY IF DRAW WITH OPACITY POSSIBLY
    Widget prevBuilder = builder;
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
            prevBuilder
          ],
        ));
    return this;
  }

  // @override
  // ChildGifBuilder buildAsOrigin() {
  //   builder = Obx(() => CustomPaint(
  //         painter: ChildGifCustomPainter(
  //             model.rect, model.frames[controller!.currentFrameIndex.value].image, Paint()),
  //         child: SizedBox(
  //             width: model.rect.width,
  //             height: model.rect.height), // to make gif animated, have to put SizedBox into this
  //       ));
  //   return this;
  // }

  @override
  Widget get origin => Obx(() => CustomPaint(
          painter: ChildGifCustomPainter(
              model.rect, model.frames[controller!.currentFrameIndex.value].image, Paint()),
          child: SizedBox(
              width: model.rect.width,
              height: model.rect.height), // to make gif animated, have to put SizedBox into this
        ));
}
