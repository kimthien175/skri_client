import 'package:get/get.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:flutter/material.dart';
import 'package:skribbl_client/utils/socket_io.dart';
import 'package:skribbl_client/widgets/widgets.dart';

import '../draw/manager.dart';

import '../utils.dart';

part 'like_dislike.dart';

class DrawViewWidget extends StatelessWidget {
  const DrawViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var size = const Size(DrawManager.width, DrawManager.height);
    return Stack(children: [
      ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          child: Container(
              height: DrawManager.height,
              width: DrawManager.width,
              decoration: const BoxDecoration(color: Colors.white),
              child: Stack(children: [
                CustomPaint(size: size, painter: _PastStepsCustomPainter()),
                CustomPaint(size: size, painter: _CurrentStepCustomPainter())
              ]))),
      Positioned(right: 0, top: 0, child: const _LikeAndDislikeButtons())
    ]);
  }
}

class _PastStepsCustomPainter extends CustomPainter {
  _PastStepsCustomPainter() : super(repaint: DrawReceiver.inst.pastStepsNotifier);
  @override
  void paint(Canvas canvas, Size size) {
    DrawReceiver.inst.tail?.drawBackward(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CurrentStepCustomPainter extends CustomPainter {
  _CurrentStepCustomPainter() : super(repaint: DrawReceiver.inst.currentStepNotifier);

  @override
  void paint(Canvas canvas, Size size) {
    DrawReceiver.inst.currentStep.forEach((key, value) => value.draw(canvas));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
