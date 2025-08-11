// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/step/plain.dart';

import '../manager.dart';
import 'step.dart';

class BrushStep extends DrawStep with GestureDrawStep {
  BrushStep.init() {
    var drawTools = DrawManager.inst;
    _brush = Paint()
      ..strokeWidth = drawTools.currentStrokeSize
      ..strokeCap = StrokeCap.round
      ..color = drawTools.currentColor;

    if (isReady) {
      enable();
    } else {
      disable();
    }
  }

  final List<Offset> _points = [];
  late final Paint _brush;

  @override
  void drawFreshly(Canvas canvas) {
    if (_points.length == 1) {
      canvas.drawPoints(PointMode.points, _points, _brush);
      return;
    }
    for (int i = 0; i < _points.length - 1; i++) {
      canvas.drawLine(_points[i], _points[i + 1], _brush);
    }
  }

  // TODO: in case user change color with shortcut, while not release mouse when drawing, what would happen?
  /// If prev step is fillstep having color is the same with this color, return false,
  ///
  /// Or `this` as only step in data that have color is white -
  /// which is the same with canvas background color, then return false as well,
  ///
  /// Otherwise good to go
  bool get isReady {
    var tail = DrawManager.inst.tail;

    if (tail == null) return (_brush.color != Colors.white);

    if (tail is PlainDrawStep && tail.color == _brush.color) return false;

    return true;
  }

  enable() {
    _onDown = _updatePoint;
    _onEnd = true;
  }

  disable() {
    _onDown = (_) {};
    _onEnd = false;
  }

  @override
  void changeColor() {
    _brush.color = DrawManager.inst.currentColor;

    if (isReady) {
      enable();
    } else {
      disable();
    }
  }

  void _updatePoint(Offset point) {
    _points.add(point);
    DrawManager.inst.currentStepRepaint.notifyListeners();
  }

  @override
  void changeStrokeSize() {
    _brush.strokeWidth = DrawManager.inst.currentStrokeSize;
  }

  @override
  void Function(Offset point) get onDown => _onDown;
  late void Function(Offset point) _onDown;

  @override
  bool get onEnd => _onEnd;
  late bool _onEnd;

  @override
  void Function(Offset point) get onUpdate => _onDown;

  // @override
  // Future<void> emitUpdateCurrent(Offset point) async {
  //   SocketIO.inst.socket.emit('draw:update_current', {'x': point.dx, 'y': point.dy});
  // }

  // @override
  // Future<void> emitDownCurrent(Offset point) async {
  //   SocketIO.inst.socket.emit('draw:down', {
  //     'type': 'brush',
  //     'size': _brush.strokeWidth,
  //     'r': _brush.color.red,
  //     'g': _brush.color.green,
  //     'b': _brush.color.blue,
  //     'a': _brush.color.alpha,
  //     'point': {'x': point.dx, 'y': point.dy}
  //   });
  // }
}
