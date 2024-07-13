library full_gif;

export 'custom_painter.dart';

import 'package:skribbl_client/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class FullGifModel extends SingleGifModel<FullGifModel> {
  static Future<FullGifModel> fromPath(String path) async {
    // load width, height
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());

    //#region load frames
    List<ui.FrameInfo> frames = [];

    var frameCount = codec.frameCount;
    for (var i = 0; i < frameCount; i++) {
      var frame = await codec.getNextFrame();
      frames.add(frame);
    }
    //#endregion

    return FullGifModel(
        path, frames, frames[0].image.width.toDouble(), frames[0].image.height.toDouble());
  }

  FullGifModel(this.path, super.frames, super._width, super._height);

  final String path;

  @override
  CustomPainter getCustomPainter(int frameIndex, Paint paint, {Offset offset = Offset.zero}) {
    return FullGifCustomPainter(frames[frameIndex].image, paint, offset: offset);
  }

  @override
  FullGifBuilder get builder => FullGifBuilder(this);
}

// ignore: must_be_immutable
class FullGifBuilder extends GifBuilder<FullGifModel> {
  FullGifBuilder(super.model, {super.key});

  @override
  GifBuilder<GifModel> init({Color? color}) {
    this.color = color;
    widget = _origin();
    return this;
  }

  @override
  GifBuilder<GifModel> initWithShadow(
      {Color? color,
      ShadowInfo info = const ShadowInfo(),
      double? height,
      double? width,
      FilterQuality filterQuality = FilterQuality.low}) {
    var finalHeight = height ?? model.height;
    var finalWidth = width ?? model.width;
    this.color = color;
    widget = Stack(clipBehavior: Clip.none, children: [
      Transform.translate(
          offset: info.offset,
          child: Image.asset(model.path,
              color: Colors.black.withOpacity(info.opacity),
              filterQuality: filterQuality,
              fit: BoxFit.contain,
              width: finalWidth,
              height: finalHeight)),
      _origin(filterQuality: filterQuality, width: finalWidth, height: finalHeight)
    ]);
    return this;
  }

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

  Widget _origin(
          {FilterQuality filterQuality = FilterQuality.low, double? width, double? height}) =>
      Image.asset(model.path,
          fit: BoxFit.contain,
          color: color,
          filterQuality: filterQuality,
          width: width,
          height: height);

  @override
  GifBuilder<GifModel> doFreezeSize() {
    widget = SizedBox(height: model.height, width: model.width, child: widget);
    return this;
  }
}
