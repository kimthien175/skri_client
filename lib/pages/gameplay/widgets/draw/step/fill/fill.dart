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

// this object never be added to tail, except its children
class FillStep extends DrawStep with GestureDrawStep {
  FillStep.init();

  @nonVirtual
  @override
  void Function(Offset point) get onUpdate => (_) {};

  @nonVirtual
  @override
  bool get onEnd {
    // check which type should fill, full or flood fill
    var drawInst = DrawManager.inst;
    var tail = drawInst.tail;

    drawInst.pushTail(((tail == null && drawInst.currentColor != Colors.white) ||
            (tail is PlainDrawStep && tail.color != drawInst.currentColor))
        ? _FullFillStep()
        : _FloodFillStep(point: _point));

    return false;
  }

  @nonVirtual
  @override
  void Function(ui.Offset point) get onDown => (point) => _point = point;

  late Offset _point;

  //#region USELESS STUFF

  @nonVirtual
  @override
  void changeColor() {}

  @nonVirtual
  @override
  void Function(ui.Canvas p1) get draw => (_) {};

  @nonVirtual
  @override
  Future<void> buildCache() => throw UnimplementedError();

  @nonVirtual
  @override
  Future<ui.Image> get cache => throw UnimplementedError();

  @nonVirtual
  @override
  void Function(ui.Canvas p1) get drawBackward => throw UnimplementedError();

  //#endregion

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
