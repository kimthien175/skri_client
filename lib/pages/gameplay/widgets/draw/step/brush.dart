// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:ui';

import 'package:skribbl_client/pages/gameplay/widgets/draw/step/fill.dart';
import 'package:skribbl_client/utils/socket_io.dart';

import '../manager.dart';
import 'step.dart';

class BrushStep extends GestureDrawStep {
  BrushStep.init({required super.id}) {
    var drawTools = DrawManager.inst;
    _brush = Paint()
      ..strokeWidth = drawTools.currentStrokeSize
      ..strokeCap = StrokeCap.round;

    changeColor();
  }

  BrushStep.defaultInit({required super.id}) {
    var drawTools = DrawManager.inst;
    _brush = Paint()
      ..strokeWidth = drawTools.currentStrokeSize
      ..strokeCap = StrokeCap.round
      ..color = DrawManager.inst.currentColor;

    enable();
  }

  List<Offset> points = [];
  late final Paint _brush;

  bool isLegitBeforeDraw() {
    var pastSteps = DrawManager.inst.pastSteps;

    if (pastSteps.isEmpty) return true;

    if (pastSteps.last is! FillStep) return true;

    if ((pastSteps.last as FillStep).isFullfillScreenWithSameColor(_brush.color)) return false;

    return true;
  }

  @override
  void changeColor() {
    _brush.color = DrawManager.inst.currentColor;
    if (isLegitBeforeDraw()) {
      enable();
    } else {
      disable();
    }
  }

  void enable() {
    onDown = enabledOnDown;
    onUpdate = enabledOnUpdate;
    onEnd = enabledOnEnd;
  }

  void disable() {
    onDown = (point) {};
    onUpdate = (point) {};
    onEnd = () => false;
  }

  void enabledOnDown(Offset point) {
    points.add(point);
    DrawManager.inst.notifyListeners();
  }

  void enabledOnUpdate(Offset point) {
    points.add(point);
    DrawManager.inst.notifyListeners();
  }

  bool enabledOnEnd() => true;

  @override
  void changeStrokeSize() {
    _brush.strokeWidth = DrawManager.inst.currentStrokeSize;
  }

  @override
  void drawAddon(Canvas canvas) {
    if (points.length == 1) {
      canvas.drawPoints(PointMode.points, points, _brush);
      return;
    }
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], _brush);
    }
  }

  @override
  Future<void> emitDownCurrent(Offset point) async {
    SocketIO.inst.socket.emit('draw:down', {
      'type': 'brush',
      'size': _brush.strokeWidth,
      'r': _brush.color.red,
      'g': _brush.color.green,
      'b': _brush.color.blue,
      'a': _brush.color.alpha,
      'point': {'x': point.dx, 'y': point.dy}
    });
  }

  // @override
  // Future<void> emitUpdateCurrent(Offset point) async {
  //   SocketIO.inst.socket.emit('draw:update_current', {'x': point.dx, 'y': point.dy});
  // }
}
