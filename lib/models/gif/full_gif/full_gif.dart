import 'package:skribbl_client/models/gif/gif.dart';
import 'package:skribbl_client/models/gif/single_gif.dart';
import 'package:skribbl_client/models/gif/full_gif/custom_painter.dart';
import 'package:skribbl_client/models/shadow_info.dart';
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

    return FullGifModel(path, frames, frames[0].image.width.toDouble(),
        frames[0].image.height.toDouble());
  }

  FullGifModel(this.path, super.frames, super._width, super._height);

  final String path;

  @override
  CustomPainter getCustomPainter(int frameIndex, Paint paint,
      {Offset offset = Offset.zero}) {
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
    widget = _origin;
    return this;
  }

  @override
  GifBuilder<GifModel> initShadowedOrigin(
      {Color? color, ShadowInfo info = const ShadowInfo()}) {
    this.color = color;
    widget = Stack(clipBehavior: Clip.none, children: [
      Transform.translate(
          offset: Offset(info.offsetLeft, info.offsetTop),
          child: Image.asset(model.path, color: Colors.black.withOpacity(info.opacity))),
      _origin
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

  Widget get _origin => Image.asset(model.path, color: color);

  @override
  GifBuilder<GifModel> doFreezeSize() {
    widget = SizedBox(height: model.height, width: model.width, child: widget);
    return this;
  }
}
