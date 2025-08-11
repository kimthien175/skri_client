import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/step/plain.dart';

import '../../manager.dart';
import 'flood_fill.dart';
import '../step.dart';

part 'fullfill.dart';
part 'floodfill.dart';

abstract class FillStep extends DrawStep with GestureDrawStep {
  factory FillStep.init() {
    var drawInst = DrawManager.inst;
    // figure which type to draw: flood fill or full fill

    if (drawInst.isEmpty) return _FirstFullFillStep();

    var tail = drawInst.tail!;

    if (tail is PlainDrawStep) return _NonFirstFullFillStep();

    return _FloodFillStep._init();
  }

  FillStep() {
    changeColor();
  }

  late Color _color;

  @nonVirtual
  @override
  void Function(Offset point) get onUpdate => (_) {};

  @nonVirtual
  @override
  void Function(Canvas) get draw => entryDraw;

  @nonVirtual
  @override
  set draw(void Function(Canvas) value) => throw Exception('forbided');

  /// main draw, child class can set it new callback to draw anything
  /// in onDown
  void Function(Canvas) entryDraw = (_) {};

  /// only `_FullFillStep` can override this
  @override
  changeColor() {
    _color = DrawManager.inst.currentColor;
  }

  // @override
  // Future<void> emitTemp() async {
  //   if (byteList == null) {
  //     SocketIO.inst.socket.emit('draw:temp', {
  //       'type': 'color',
  //       'hashCode': hashCode,
  //       'r': _color.red,
  //       'g': _color.green,
  //       'b': _color.blue,
  //       'a': _color.alpha
  //     });
  //   } else {
  //     SocketIO.inst.socket
  //         .emit('draw:temp', {'type': 'Uint8List', 'hashCode': hashCode, 'Uint8List': byteList});
  //   }
  // }
}
