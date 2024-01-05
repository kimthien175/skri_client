import 'package:cd_mobile/models/gif/builder.dart';
import 'package:cd_mobile/models/gif/child_gif/builder.dart';
import 'package:cd_mobile/models/gif/child_gif/custom_painter.dart';
import 'package:cd_mobile/models/gif/model.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ChildGifModel extends GifModel {
  ChildGifModel(this._rect, List<ui.FrameInfo> frames)
      : super('', frames, _rect.width, _rect.height);

  final Rect _rect;
  @override
  Rect get rect => _rect;

  @override
  CustomPainter getCustomPainter(int frameIndex, Paint paint, {Offset offset = Offset.zero}) {
    return ChildGifCustomPainter(rect, frames[frameIndex].image, paint);
  }

  @override
  GifBuilder get builder => ChildGifBuilder(this);
}