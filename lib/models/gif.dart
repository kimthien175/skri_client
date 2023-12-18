import 'dart:async';

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
    var img = (await codec.getNextFrame()).image;

    return GifModel(path, img.width.toDouble(), img.height.toDouble());
  }

  GifModel(this._path, this._width, this._height);
  final String _path;
  final double _width;
  double get width => _width;

  final double _height;
  double get height => _height;

  double get ratio => _width / _height;

  Gif widget() => Gif(this);

  GifWithShadow widgetWithShadow({ShadowInfo info = const ShadowInfo()}) => GifWithShadow(this, info);
}

class ChildGifModel extends GifModel {
  ChildGifModel(this._rect, this._frames)
      : super('', _rect.width.toDouble(), _rect.height.toDouble());

  final Rect _rect;
  Rect get rect => _rect;

  final List<ui.FrameInfo> _frames;
  List<ui.FrameInfo> get frames => _frames;

  @override
  ChildGif widget() =>ChildGif(this);
}

class Gif<T extends GifModel> extends StatelessWidget {
  const Gif(this.model, {super.key});

  final T model;

  //#region Shadow

  Widget getShadow() {
    // TODO GIF GET SHADOW
    return Container();
  }
  //#endregion

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
              painter: _CustomPainter(
                  model.rect, model.frames[controller.currentFrameIndex.value].image),
              child: SizedBox(
                  width: model.rect.width,
                  height:
                      model.rect.height), // to make gif animated, have to put SizedBox into this
            )));
  }
}

class ChildGifController extends GetxController {
  ChildGifController(this.frameCount, this.duration);

  RxInt currentFrameIndex = 0.obs;

  final int frameCount;
  final Duration duration;
  late Timer timer;

  switchFrame() {
    currentFrameIndex++;
    if (currentFrameIndex.value == frameCount) {
      currentFrameIndex.value = 0;
    }
    timer = Timer(duration, switchFrame);
  }

  //ui.Image get currentFrame => frame[currentFrameIndex.value].image;

  void startTimer() {
    timer = Timer(duration, switchFrame);
  }

  void pauseTimer() {
    timer.cancel();
  }
}

class _CustomPainter extends CustomPainter {
  _CustomPainter(this.rect, this.img);
  final Rect rect;
  final ui.Image img;
  final Paint _paint = Paint();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(img, rect, Rect.fromLTWH(0, 0, rect.width, rect.height), _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
