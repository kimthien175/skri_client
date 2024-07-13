library gif;

export 'full_gif/full_gif.dart';
export 'controlled_gif/controlled_gif.dart';
export 'single_gif.dart';

import 'package:skribbl_client/models/shadow_info.dart';
import 'package:flutter/material.dart';

abstract class GifModel<MODEL_TYPE extends GifModel<MODEL_TYPE>> {
  GifModel(this._width, this._height);

  final double _width;
  double get width => _width;

  final double _height;
  double get height => _height;

  /// IF NONE OF BUILDER METHODS BEHIND THIS, THE WIDGET WOULD BE NULL
  GifBuilder<MODEL_TYPE> get builder;

  CustomPainter getCustomPainter(int frameIndex, Paint paint, {Offset offset = Offset.zero});
}

// ignore: must_be_immutable
abstract class GifBuilder<MODEL_TYPE extends GifModel<MODEL_TYPE>> extends StatelessWidget {
  GifBuilder(this.model, {super.key});
  MODEL_TYPE model;
  Widget? widget;
  Color? color;

  GifBuilder initWithShadow(
      {Color? color,
      ShadowInfo info = const ShadowInfo(),
      FilterQuality filterQuality,
      double? height,
      double? width});

  GifBuilder init({Color? color});

  GifBuilder doScale(double ratio);
  GifBuilder doFitSize({double? height, double? width});
  GifBuilder doFreezeSize();

  @override
  Widget build(BuildContext context) {
    return widget!;
  }
}
