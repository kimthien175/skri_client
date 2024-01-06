import 'package:cd_mobile/models/gif/gif.dart';
import 'package:cd_mobile/models/gif/single_gif/single_gif.dart';
import 'package:cd_mobile/models/gif/single_gif/full_gif/custom_painter.dart';
import 'package:cd_mobile/models/shadow_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class FullGifModel extends SingleGifModel {
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
  // @override
  // FullGifBuilder withFixedSize() {
  //   var preBuilder = builder;
  //   builder = SizedBox(height: model.height, width: model.width, child: preBuilder);
  //   return this;
  // }

  @override
  FullGifBuilder withShadow({ShadowInfo info = const ShadowInfo()}) {
    builder = Stack(clipBehavior: Clip.none, children: [
      Transform.translate(
          offset: Offset(info.offsetLeft, info.offsetTop),
          child: Image.asset(model.path, color: Color.fromRGBO(0, 0, 0, info.opacity))),
      origin
    ]);
    return this;
  }

  // @override
  // FullGifBuilder buildAsOrigin() {
  //   builder = origin;
  //   return this;
  // }

  @override
  FullGifBuilder withFixedSize() {
    builder = SizedBox(height: model.height, width: model.width, child: builder);
    return this;
  }

  @override
  Widget get origin => Image.asset(model.path);
}
