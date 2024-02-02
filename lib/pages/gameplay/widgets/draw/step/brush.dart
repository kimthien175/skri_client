import 'dart:ui';

import '../manager.dart';
import 'step.dart';

class BrushStep extends DrawStep {
  BrushStep.init({required super.id}) {
    var drawTools = DrawTools.inst;
    _brush = Paint()
      ..strokeWidth = drawTools.currentStrokeSize
      ..color = drawTools.currentColor
      ..strokeCap = StrokeCap.round;
  }
  List<Offset> points = [];
  late final Paint _brush;

  @override
  void changeColor(Color color) {
    _brush.color = color;
  }

  @override
  void changeStrokeSize(double size) {
    _brush.strokeWidth = size;
  }

  @override
  void onDown(Offset point) {
    points.add(point);
  }

  @override
  void onUpdate(Offset point) {
    points.add(point);
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

  // @override
  // Future<void> emitDownCurrent(Offset point) async {
  //   // var rawPoints = [];
  //   // for (int i = 0; i < points.length; i++) {
  //   //   rawPoints.add({'x': points[i].dx, 'y': points[i].dy});
  //   // }
  //   SocketIO.inst.socket.emit('draw:down_current', {
  //     'type': 'brush',
  //     'size': _brush.strokeWidth,
  //     'r': _brush.color.red,
  //     'g': _brush.color.green,
  //     'b': _brush.color.blue,
  //     'a': _brush.color.alpha,
  //     'point': {'x': point.dx, 'y': point.dy}
  //   });
  // }

  // @override
  // Future<void> emitUpdateCurrent(Offset point) async {
  //   SocketIO.inst.socket.emit('draw:update_current', {'x': point.dx, 'y': point.dy});
  // }
}