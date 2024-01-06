import 'package:cd_mobile/models/gif/gif.dart';
import 'package:cd_mobile/models/gif/avatar/builder.dart';
import 'package:cd_mobile/models/gif/avatar/custom_painter.dart';
import 'package:cd_mobile/models/gif/single_gif/single_gif.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class AvatarModel extends GifModel {
  late SingleGifModel color;
  late SingleGifModel eyes;
  late SingleGifModel mouth;

  static AvatarModel init(int color, int eyes, int mouth) {
    var gif = GifManager.inst;
    var colorMod = gif.color(color);
    var eyesMod = gif.eyes(eyes);
    var mouthMod = gif.mouth(mouth);
    return AvatarModel._internal(colorMod, eyesMod, mouthMod, colorMod.width, colorMod.height);
  }

  AvatarModel._internal(this.color, this.eyes, this.mouth, super.width, super.height);

  @override
  AvatarBuilder get builder => AvatarBuilder(this);

  /// offset is useless
  @override
  CustomPainter getCustomPainter(int frameIndex, ui.Paint paint,
          {ui.Offset offset = Offset.zero}) =>
      AvatarCustomPainter(this, frameIndex, paint);
}
