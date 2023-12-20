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

class ChildGifCustomPainter extends CustomPainter {
  ChildGifCustomPainter(this.rect, this.img, this._paint);
  final Rect rect;
  final ui.Image img;
  final Paint _paint;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(img, rect, Rect.fromLTWH(0, 0, rect.width, rect.height), _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

