import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class FullGifCustomPainter extends CustomPainter{
  FullGifCustomPainter(this.image, this._paint, {this.offset = Offset.zero});

  final ui.Image image;
  final Paint _paint;
  final Offset offset;
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, offset, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}