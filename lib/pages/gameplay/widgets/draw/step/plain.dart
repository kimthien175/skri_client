import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/step/step.dart';
import 'dart:ui' as ui;

mixin PlainDrawStep on DrawStep {
  Color get color;

  /// do nothing, for plain color just let steps draw its nature, no need cache
  @nonVirtual
  @override
  Future<bool> buildCache() async => true;

  @override
  Future<ui.Image> get cache => throw Exception('PlainDrawStep never be previous of FloodFillStep');
}
