import 'dart:ui' as ui;

import 'package:flutter/material.dart';

abstract class DrawStep {
  late final int id;

  //#region For linked list
  DrawStep? prev;
  DrawStep? next;

  void unlink() {
    prev?.next = next;
    next?.prev = prev;
  }

  /// chain up, set id, return `newStep`
  DrawStep chainUp(DrawStep newStep) {
    next = newStep;

    newStep.prev = this;
    newStep.id = id + 1;

    return newStep;
  }

  //#endregion

  //#region For caching
  Future<void> buildCache();

  /// for FloodFillStep as next DrawStep to access
  Future<ui.Image> get cache;
  //#endregion

  /// loop to this into previous step, finally draw freshly
  /// expected to be that when previous step have temp or plain draw, the loop would stop
  void Function(Canvas) get drawBackward;

  // Future<void> emitTemp() async {
  //   temp!
  //       .toImage(DrawManager.width.toInt(), DrawManager.height.toInt())
  //       .then((value) => value.toByteData(format: ImageByteFormat.png))
  //       .then((value) {
  //     if (value != null) {
  //       SocketIO.inst.socket.emit('draw:temp',
  //           {'type': 'Uint8List', 'hashCode': hashCode, 'Uint8List': value.buffer.asUint8List()});
  //     }
  //   });
  // }

  // Future<void> emitDownCurrent(Offset point) async {}
  // Future<void> emitUpdateCurrent(Offset point) async {}
}

mixin GestureDrawStep on DrawStep {
  void Function(Offset point) get onDown;
  void Function(Offset point) get onUpdate;
  bool get onEnd;

  void changeColor();

  /// only Brush step use this
  void changeStrokeSize() {}

  void Function(Canvas) get draw;
}
