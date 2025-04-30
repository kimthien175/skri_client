import 'package:flutter/material.dart';

class ShadowInfo {
  const ShadowInfo({this.offset = const Offset(3, 3), this.opacity = 0.3});
  final Offset offset;
  final double opacity;

  static Shadow get shadow =>
      const Shadow(color: Color.fromRGBO(0, 0, 0, 0.3), offset: Offset(3, 3));
}
