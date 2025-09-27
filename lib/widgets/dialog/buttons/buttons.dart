library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/widgets.dart';
part 'button_child.dart';
part 'row.dart';
part 'button_parent.dart';

abstract class GameDialogButtons {
  static TextStyle get textStyle => const TextStyle(
      fontSize: 15,
      fontVariations: [FontVariation.weight(800)],
      shadows: [Shadow(color: Color(0x90000000), offset: Offset(2.3, 2.3))]);
}

typedef OnTapCallback = Future<bool> Function(Future<bool> Function() onQuit);
