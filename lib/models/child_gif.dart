import 'dart:async';

import 'package:flutter/material.dart';
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

// ignore: must_be_immutable
class ChildGif extends StatelessWidget {
  ChildGif(this.rect, List<ui.FrameInfo> frames, {super.key}) {
    controller = ChildGifController(frames);
  }

  final Rect rect;
  late ChildGifController controller;

  double get width=>rect.right - rect.left;
  double get height=>rect.bottom - rect.top;

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomPaint(
          painter: MyCustomPainter(rect, controller.currentFrame),
          child: SizedBox(width: rect.width, height: rect.height),
        ));
  }
}
