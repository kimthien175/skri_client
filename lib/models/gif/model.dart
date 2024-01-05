import 'package:cd_mobile/models/gif/custom_painter.dart';
import 'package:cd_mobile/models/gif/builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class GifModel {
  static Future<GifModel> fromPath(String path) async {
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

    return GifModel(
        path, frames, frames[0].image.width.toDouble(), frames[0].image.height.toDouble());
  }

  GifModel(this.path, this.frames, this._width, this._height);

  final String path;
  late final double _width;
  double get width => _width;

  late final double _height;
  double get height => _height;

  //double get ratio => _width / _height;

  //Widget get getWidget => Gif(this);

  List<ui.FrameInfo> frames;
  Rect get rect => Rect.zero;

  CustomPainter getCustomPainter(int frameIndex, Paint paint, {Offset offset = Offset.zero}) {
    return GifCustomPainter(frames[frameIndex].image, paint, offset: offset);
  }

  GifBuilder get builder => GifBuilder(this);
}


// class FixedSizeGif<T extends GifModel> extends Gif<T> {
//   const FixedSizeGif(super.model, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Image.asset(model._path, height: model.height, width: model.width);
//   }
// }

// class GifWithShadow extends Gif {
//   const GifWithShadow(super.model, {this.shadowInfo = const ShadowInfo(), super.key});

//   final ShadowInfo shadowInfo;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(clipBehavior: Clip.none, children: [
//       Transform.translate(
//           offset: Offset(shadowInfo.offsetLeft, shadowInfo.offsetTop),
//           child: Image.asset(model._path, color: Color.fromRGBO(0, 0, 0, shadowInfo.opacity))),
//       Image.asset(model._path)
//     ]);
//   }
// }


