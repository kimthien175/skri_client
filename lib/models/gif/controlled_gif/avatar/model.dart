import 'dart:ui' as ui;

import 'package:skribbl_client/models/models.dart';
import 'package:flutter/material.dart';

typedef GifCustomPainterBuilder = CustomPainter Function(int frameIndex, Paint paint);

class AvatarModel extends GifModel<AvatarModel> {
  SingleGifModel color;
  SingleGifModel eyes;
  SingleGifModel mouth;
  bool winner;

  factory AvatarModel.fromJSON(Map<String, dynamic> data) =>
      AvatarModel(data['color'], data['eyes'], data['mouth']);

  factory AvatarModel(int color, int eyes, int mouth, {bool winner = false}) {
    var gif = GifManager.inst;
    var colorMod = gif.color[color];
    var eyesMod = gif.eyes[eyes];
    var mouthMod = gif.mouth[mouth];
    return AvatarModel._internal(colorMod, eyesMod, mouthMod, colorMod.width, colorMod.height,
        winner: winner);
  }

  AvatarModel._internal(this.color, this.eyes, this.mouth, super.width, super.height,
      {this.winner = false});

  /// offset is useless
  @override
  CustomPainter getCustomPainter(int frameIndex, ui.Paint paint,
          {ui.Offset offset = Offset.zero}) =>
      AvatarCustomPainter(this, frameIndex, paint);

  static GifCustomPainterBuilder get crownCustomPainter =>
      (int frameIndex, Paint paint) => GifManager.inst
          .misc('crown')
          .getCustomPainter(frameIndex, paint, offset: const Offset(-3.5, -10.5));

  @override
  AvatarBuilder get builder => AvatarBuilder(this);

  Map<String, dynamic> toJSON() {
    return {'color': color.index, 'eyes': eyes.index, 'mouth': mouth.index};
  }
}
