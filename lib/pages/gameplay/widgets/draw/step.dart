import 'dart:typed_data';
import 'dart:ui';

import 'package:cd_mobile/utils/socket_io.dart';
import 'package:flutter/foundation.dart';

import 'flood_fill.dart';
import 'manager.dart';

abstract class DrawStep {
  DrawStep({required this.id});

  int id;
  Picture? temp;

  void onDown(Offset point) {}
  void onUpdate(Offset point) {}

  /// DECIDE PUSH STEP OR NOT
  bool onEnd() {
    return true;
  }

  void changeColor(Color color) {}
  void changeStrokeSize(double size) {}

  final recorder = PictureRecorder();

  Future<void> compileTemp() async {
    var pictureCanvas = Canvas(recorder);

    // draw temp of previous node
    if (id > 0) {
      DrawManager.inst.pastSteps[id - 1].drawTemp(pictureCanvas);
    }
    drawCurrent(pictureCanvas);
    temp = recorder.endRecording();
  }

  /// addOn, no previous drawing
  void drawCurrent(Canvas canvas);
  void drawTemp(Canvas canvas) {
    canvas.drawPicture(temp!);
  }

  Future<void> emitTemp() async {
    temp!
        .toImage(DrawManager.width.toInt(), DrawManager.height.toInt())
        .then((value) => value.toByteData(format: ImageByteFormat.png))
        .then((value) {
      if (value != null) {
        SocketIO.inst.socket.emit('draw:temp',
            {'type': 'Uint8List', 'hashCode': hashCode, 'Uint8List': value.buffer.asUint8List()});
      }
    });
  }

  Future<void> emitCurrent();
}

class FillStep extends DrawStep {
  FillStep.init({required super.id});

  Offset? _point;
  Color _color = DrawTools.inst.currentColor;

  @override
  void changeColor(Color color) {
    _color = color;
  }

  @override
  void onDown(Offset point) {
    _point = point;
  }

  @override
  bool onEnd() {
    if (DrawManager.inst.pastSteps.isNotEmpty) {
      var preStep = DrawManager.inst.pastSteps.last;

      if (preStep is! FillStep) return true;
      if (preStep._color == _color && preStep.fillWholeScreen) return false;
    } else {
      fillWholeScreen = true;
    }
    return true;
  }

  bool fillWholeScreen = false;

  @override
  Future<void> compileTemp() async {
    var pictureCanvas = Canvas(recorder);

    // CASE 1: first Step, just fill screen
    if (id == 0) {
      // fill whole screen
      pictureCanvas.drawColor(_color, BlendMode.src);
      temp = recorder.endRecording();
      return;
    }

    // CASE 2: FILL SCREEN IF PRESTEP IS FILLSTEP, FOR BETTER PERFORMANCE
    var preStep = DrawManager.inst.pastSteps[id - 1];
    if ((preStep is FillStep && preStep.fillWholeScreen) || preStep is ClearStep) {
      // fill whole screen
      pictureCanvas.drawColor(_color, BlendMode.src);
      temp = recorder.endRecording();
      return;
    }

    // CASE 3:

    // draw temp of previous node
    DrawManager.inst.pastSteps[id - 1].drawTemp(pictureCanvas);

    // get temp for flood fill
    temp = recorder.endRecording();

    // record new Picture
    pictureCanvas = Canvas(recorder);

    try {
      var floodfiller = await FloodFiller.init(
          image: await temp!.toImage(DrawManager.width.toInt(), DrawManager.height.toInt()),
          point: _point!,
          fillColor: _color);

      byteList = await floodfiller.prepareAndFill();
      var codec = await instantiateImageCodec(
          byteList!); //, targetWidth: decodedImage.width, targetHeight: height)

      var frameInfo = await codec.getNextFrame();

      pictureCanvas.drawImage(frameInfo.image, const Offset(0, 0), Paint());
    } finally {
      temp = recorder.endRecording();
    }
  }

  /// Unint8list
  Uint8List? byteList;

  @override
  void drawCurrent(Canvas canvas) {}

  @override
  Future<void> emitTemp() async {
    if (byteList == null) {
      SocketIO.inst.socket.emit('draw:temp', {
        'type': 'color',
        'hashCode': hashCode,
        'r': _color.red,
        'g': _color.green,
        'b': _color.blue,
        'a': _color.alpha
      });
    } else {
      SocketIO.inst.socket
          .emit('draw:temp', {'type': 'Uint8List', 'hashCode': hashCode, 'Uint8List': byteList});
    }
  }

  @override
  Future<void> emitCurrent() async {}
}

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
  void drawCurrent(Canvas canvas) {
    if (points.length == 1) {
      canvas.drawPoints(PointMode.points, points, _brush);
      return;
    }
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], _brush);
    }
  }

  @override
  Future<void> emitCurrent() async {
    var rawPoints = [];
    for (int i = 0; i < points.length; i++) {
      rawPoints.add({'x': points[i].dx, 'y': points[i].dy});
    }
    SocketIO.inst.socket.emit('draw:current', {
      'type': 'brush',
      'size': _brush.strokeWidth,
      'r': _brush.color.red,
      'g': _brush.color.green,
      'b': _brush.color.blue,
      'a': _brush.color.alpha,
      'points': rawPoints
    });
  }
}

class ClearStep extends DrawStep {
  ClearStep({required super.id});

  @override
  void drawCurrent(Canvas canvas) {}

  @override
  void drawTemp(Canvas canvas) {}

  @override
  Future<void> compileTemp() async {}

  @override
  Future<void> emitTemp() async {
    SocketIO.inst.socket.emit('draw:clear');
  }

  @override
  Future<void> emitCurrent() async {}
}
