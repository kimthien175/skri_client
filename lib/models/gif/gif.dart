import 'package:cd_mobile/models/gif/controller.dart';
import 'package:cd_mobile/models/gif/custom_painter.dart';
import 'package:cd_mobile/models/shadow_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';


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

    return GifModel(path, frames, frames[0].image.width.toDouble(), frames[0].image.height.toDouble());
  }

  GifModel(this._path, this._frames, this._width, this._height);

  final String _path;
  late final double _width;
  double get width => _width;

  late final double _height;
  double get height => _height;

  //double get ratio => _width / _height;

  Gif widget() => Gif(this);

  GifWithShadow widgetWithShadow({ShadowInfo info = const ShadowInfo()}) =>
      GifWithShadow(this, info);


  final List<ui.FrameInfo> _frames;
  List<ui.FrameInfo> get frames => _frames;
  Rect get rect => Rect.zero;

  CustomPainter getCustomPainter(int frameIndex, Paint paint, {Offset offset = Offset.zero}) {
    return GifCustomPainter(_frames[frameIndex].image, paint, offset: offset);
  }
}

class ChildGifModel extends GifModel {
  ChildGifModel(this._rect, List<ui.FrameInfo> frames):super('', frames, _rect.width, _rect.height);

  final Rect _rect;
  @override
  Rect get rect => _rect;


  @override
  List<ui.FrameInfo> get frames => _frames;

  @override
  ChildGif widget() => ChildGif(this);

  @override
  CustomPainter getCustomPainter(int frameIndex, Paint paint, {Offset offset = Offset.zero}) {
    return ChildGifCustomPainter(rect, frames[frameIndex].image, paint);
  }
}


class Gif<T extends GifModel> extends StatelessWidget {
  const Gif(this.model, {super.key});

  final T model;

  @override
  Widget build(BuildContext context) {
    return Image.asset(model._path);
  }
}

class GifWithShadow extends Gif {
  const GifWithShadow(super.model, this.shadowInfo, {super.key});

  final ShadowInfo shadowInfo;

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      Transform.translate(
          offset: Offset(shadowInfo.offsetLeft, shadowInfo.offsetTop),
          child: Image.asset(model._path, color: Color.fromRGBO(0, 0, 0, shadowInfo.opacity))),
      Image.asset(model._path)
    ]);
  }
}

class ChildGif<T extends ChildGifModel> extends Gif<T> {
  ChildGif(T model, {super.key}) : super(model) {
    controller = ChildGifController(model.frames.length, model.frames[0].duration);
  }

  late final ChildGifController controller;

  @override
  Widget build(BuildContext context) {
    // TODO: is VisibilityDetector is a goodway?
    return VisibilityDetector(
        key: Key(hashCode.toString()),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction == 0) {
            controller.pauseTimer();
          } else {
            controller.startTimer();
          }
        },
        child: Obx(() => CustomPaint(
              painter: ChildGifCustomPainter(
                  model.rect, model.frames[controller.currentFrameIndex.value].image, Paint()),
              child: SizedBox(
                  width: model.rect.width,
                  height:
                      model.rect.height), // to make gif animated, have to put SizedBox into this
            )));
  }
}



