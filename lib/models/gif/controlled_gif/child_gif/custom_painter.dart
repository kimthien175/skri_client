import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ChildGifCustomPainter extends CustomPainter {
  ChildGifCustomPainter(this.rect, this.img, this._paint, {this.offset = Offset.zero});
  final Rect rect;
  final ui.Image img;
  final Paint _paint;
  final Offset offset;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(offset.dx, offset.dy);
    canvas.drawImageRect(img, rect, Rect.fromLTWH(0, 0, rect.width, rect.height), _paint);
    canvas.translate(-offset.dx, -offset.dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
