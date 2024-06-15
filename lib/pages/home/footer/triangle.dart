import 'dart:math';

import 'package:cd_mobile/pages/home/footer/footer.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SvgTriangle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PanelStyles.color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SvgTriangle oldDelegate) => true;
}

class Triangle extends StatelessWidget {
  const Triangle({this.height = 40, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomPaint(
          painter: SvgTriangle(),
          size: Size(
              Get.find<HomeController>().isWebLayout.value
                  ? max(context.width, Footer.webWidth)
                  : context.width,
              height),
        ));
  }
}
