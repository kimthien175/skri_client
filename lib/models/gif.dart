import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:get/get.dart';

class MyCustomPainter extends CustomPainter {
  MyCustomPainter(this.rect, this.img);
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

class ChildGifController extends GetxController {
  ChildGifController(this.frames);

  RxInt currentFrameIndex = 0.obs;
  final List<ui.FrameInfo> frames;
  late Timer timer;

  switchFrame() {
    currentFrameIndex++;
    if (currentFrameIndex.value == frames.length) currentFrameIndex.value = 0;

    timer = Timer(frames[currentFrameIndex.value].duration, switchFrame);
  }

  ui.Image get currentFrame => frames[currentFrameIndex.value].image;

  @override
  InternalFinalCallback<void> get onStart {
    timer = Timer(frames[currentFrameIndex.value].duration, switchFrame);

    return super.onStart;
  }

  @override
  void onClose() {
    timer.cancel();
    super.onClose();
  }
}

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
  double get width=>_width;

  final double _height;
  double get height =>_height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: _width, height: _height, child: Image.asset(_path));
  }
}

// ignore: must_be_immutable
class ChildGif extends Gif {
  ChildGif(this.rect, List<ui.FrameInfo> frames, {super.key}) : super('', rect.width, rect.height) {
    controller = ChildGifController(frames);
  }

  final Rect rect;
  late ChildGifController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomPaint(
          painter: MyCustomPainter(rect, controller.currentFrame),
          child: SizedBox(width: rect.width, height: rect.height),
        ));
  }
}
