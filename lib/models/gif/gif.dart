import 'package:cd_mobile/models/shadow_info.dart';
import 'package:flutter/material.dart';

abstract class GifModel {
  GifModel(this._width, this._height);

  final double _width;
  double get width => _width;

  final double _height;
  double get height => _height;

  /// IF NONE OF BUILDER METHODS BEHIND THIS, THE WIDGET WOULD BE NULL
  GifBuilder get builder;

  CustomPainter getCustomPainter(int frameIndex, Paint paint, {Offset offset = Offset.zero});
}

// ignore: must_be_immutable
abstract class GifBuilder<MODEL_TYPE extends GifModel> extends StatelessWidget {
  GifBuilder(this.model, {super.key});
  late Widget builder;
  MODEL_TYPE model;

  GifBuilder withFixedSize();
  GifBuilder withShadow({ShadowInfo info = const ShadowInfo()});

  /// this will return widget without model attached
  Widget get origin;

  GifBuilder asOrigin(){
    builder = origin;
    return this;
  }

  @override
  Widget build(BuildContext context) => builder;
}
