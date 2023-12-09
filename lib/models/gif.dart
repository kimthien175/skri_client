import 'dart:async';

import 'package:cd_mobile/models/shadow_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Gif extends StatelessWidget {
  static Future<Gif> fromPath(String path) async {
    // load width, height
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    var img = (await codec.getNextFrame()).image;

    return Gif(path, img.width.toDouble(), img.height.toDouble());
  }

  const Gif(this._path, this._width, this._height, {super.key});

  final String _path;

  final double _width;
  double get width => _width;

  final double _height;
  double get height => _height;

  //#region Shadow
  GifWithShadow withShadow({ShadowInfo info = const ShadowInfo()}) {
    return GifWithShadow(_path, _width, _height, info);
  }

  Widget getShadow() {
    return Container();
  }
  //#endregion

  @override
  Widget build(BuildContext context) {
    return Image.asset(_path);
  }
}

class GifWithShadow extends Gif {
  const GifWithShadow(super._path, super._width, super._height, this.shadowInfo, {super.key});

  final ShadowInfo shadowInfo;

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      Transform.translate(
          offset: Offset(shadowInfo.offsetLeft, shadowInfo.offsetTop),
          child: Image.asset(_path, color: Color.fromRGBO(0, 0, 0, shadowInfo.opacity))),
      Image.asset(_path)
    ]);
  }
}

class ChildGif extends Gif {
  ChildGif(this.rect, List<ui.FrameInfo> frames, {super.key}) : super('', rect.width, rect.height) {
    controller = ChildGifController(frames);
  }

  final Rect rect;
  late final ChildGifController controller;

  @override
  Widget build(BuildContext context) {
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
              painter: _CustomPainter(rect, controller.currentFrame),
              child: SizedBox(width: rect.width, height: rect.height),
            )));
  }
}

class ChildGifController extends GetxController {
  ChildGifController(this.frames);

  RxInt currentFrameIndex = 0.obs;
  final List<ui.FrameInfo> frames;
  late Timer timer;

  switchFrame() {
    currentFrameIndex++;
    if (currentFrameIndex.value == frames.length) {
      currentFrameIndex.value = 0;
    }
    timer = Timer(frames[currentFrameIndex.value].duration, switchFrame);
  }

  ui.Image get currentFrame => frames[currentFrameIndex.value].image;

  void startTimer() {
    timer = Timer(frames[currentFrameIndex.value].duration, switchFrame);
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
