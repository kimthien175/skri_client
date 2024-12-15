library game_dialog_buttons;

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/widgets.dart';
part 'button_child.dart';
part 'row.dart';
part 'button_parent.dart';

abstract class GameDialogButtons {
  // const factory GameDialogButtons.row({required List<GameDialogButton> children, double gap}) =
  //     _RowRenderObjectWidget;

  //const GameDialogButtons({super.key});

  static TextStyle get textStyle => const TextStyle(
      fontSize: 15,
      fontVariations: [FontVariation.weight(800)],
      shadows: [Shadow(color: Color(0x90000000), offset: Offset(2.3, 2.3))]);
}

typedef OnTapCallback = Future<bool> Function(Future<bool> Function() onQuit);

// class _Column extends _Row {
//   const _Column({required super.children});
//   @override
//   Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: children);
// }


