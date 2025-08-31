import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../utils.dart';
import '../manager.dart';
import 'plain.dart';
import 'step.dart';

class BrushStep extends DrawStep with GestureDrawStep {
  @override
  String get type => TYPE;

  // ignore: constant_identifier_names
  static const String TYPE = 'brush';

  @override
  Map<String, dynamic> get toPrivateJSON => {
        'stroke_width': _brush.strokeWidth,
        'color': _brush.color.toJSON,
        'points': _points.toJSON,
        'private_id': privateId
      };

  BrushStep.fromJSON(dynamic json) {
    _brush = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = json['stroke_width']
      ..color = JSONColor.fromJSON(json['color']);

    for (var point in json['points']) {
      _points.add(JSONOffset.fromJSON(point));
    }
    privateId = json['private_id'];
  }

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
    privateId = hashCode;
  }

  final List<Offset> _points = [];
  late final Paint _brush;

  void _drawFreshly(Canvas canvas) {
    if (_points.length == 1) {
      canvas.drawPoints(ui.PointMode.points, _points, _brush);
      return;
    }
    for (int i = 0; i < _points.length - 1; i++) {
      canvas.drawLine(_points[i], _points[i + 1], _brush);
    }
  }

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

  void enable() {
    _onDown = _startPoint;
    _onUpdate = _updatePoint;
    _onEnd = () {
      if (_points.isEmpty) return false;

      isEnded = true;
      DrawEmitter.inst.endCurrent(privateId);
      return true;
    };
  }

  bool isEnded = true;

  void disable() {
    _onDown = (_) {};
    _onEnd = () => false;
  }

  @override
  void changeColor() {
    if (!isEnded) return DrawManager.inst.onEnd();

    _brush.color = DrawManager.inst.currentColor;

    if (isReady) {
      enable();
    } else {
      disable();
    }
  }

  void _startPoint(Offset point) {
    isEnded = false;
    _points.add(point);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    DrawManager.inst.currentStepRepaint.notifyListeners();

    DrawEmitter.inst.startCurrent({
      'stroke_width': _brush.strokeWidth,
      'color': _brush.color.toJSON,
      'points': [point.toJSON],
      'private_id': privateId
    });
  }

  void _updatePoint(Offset point) {
    if (isEnded) return _startPoint(point);

    _points.add(point);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    DrawManager.inst.currentStepRepaint.notifyListeners();

    DrawEmitter.inst
        .updateCurrent({'private_id': privateId, 'i': _points.length - 1, 'point': point.toJSON});
  }

  @override
  void changeStrokeSize() {
    _brush.strokeWidth = DrawManager.inst.currentStrokeSize;
  }

  @override
  void Function(Offset point) get onDown => _onDown;
  late void Function(Offset point) _onDown;

  @override
  bool get onEnd => _onEnd();
  late bool Function() _onEnd;

  @override
  void Function(Offset point) get onUpdate => _onUpdate;
  late void Function(Offset point) _onUpdate;

  //#region Cache

  final Completer<ui.Image> _completer = Completer<ui.Image>();

  @override
  Future<ui.Image> get cache => _completer.future;

  @override
  Future<bool> buildCache() async {
    var recorder = ui.PictureRecorder();
    var canvas = ui.Canvas(recorder);

    drawBackward(canvas);

    var result = recorder.endRecording();

    // cache done
    _completer.complete(result.toImage(DrawManager.width.toInt(), DrawManager.height.toInt()));

    _drawBackward = (Canvas canvas) {
      canvas.drawPicture(result);
    };

    return true;
  }

  late void Function(Canvas) _drawBackward = (Canvas canvas) {
    prev?.drawBackward(canvas);
    _drawFreshly(canvas);
  };

  @override
  void Function(Canvas) get drawBackward => _drawBackward;

  @override
  void Function(ui.Canvas p1) get draw => _drawFreshly;

  //#endregion

  late final int privateId;
}

class SpectatorBrushStep extends DrawStep with GestureDrawStep {
  SpectatorBrushStep.fromJSON(dynamic json) {
    brush = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = json['stroke_width']
      ..color = JSONColor.fromJSON(json['color']);

    pointsMap = {0: JSONOffset.fromJSON(json['points'][0])};

    privateId = json['private_id'];
  }

  Completer<void> clear = Completer();

  late final int privateId;

  late final Map<int, Offset> pointsMap;
  late final Paint brush;

  void Function(dynamic) get receivePoint => (data) {
        var i = data['i'];
        var point = JSONOffset.fromJSON(data['point']);
        pointsMap[i] = point;
      };

  @override
  void Function(Canvas) get draw => (Canvas canvas) {
        pointsMap.forEach((index, point) {
          var nextPoint = pointsMap[index + 1];
          if (nextPoint != null) canvas.drawLine(pointsMap[index]!, nextPoint, brush);
        });
      };

  @override
  Future<bool> buildCache() => throw UnimplementedError();

  @override
  Future<ui.Image> get cache => throw UnimplementedError();

  @override
  void Function(ui.Canvas p1) get drawBackward => throw UnimplementedError();

  @override
  Map<String, dynamic> get toPrivateJSON => throw UnimplementedError();

  @override
  String get type => throw UnimplementedError();

  @override
  void changeColor() => throw UnimplementedError();

  @override
  void Function(ui.Offset point) get onDown => throw UnimplementedError();

  @override
  bool get onEnd => throw UnimplementedError();

  @override
  void Function(ui.Offset point) get onUpdate => throw UnimplementedError();
}
