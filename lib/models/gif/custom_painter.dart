import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GifCustomPainter extends CustomPainter{
  GifCustomPainter(this.image, this._paint, {this.offset = Offset.zero});

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