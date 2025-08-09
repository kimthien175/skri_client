import 'dart:ui';

import '../manager.dart';

abstract class DrawStep {
  DrawStep({required this.id});

  int id;

  late final Picture cachedRecursive;

  //#region For caching
  Future<void> buildCache() async {
    var recorder = PictureRecorder();
    var canvas = Canvas(recorder);
    drawRecursivelyFreshly(canvas);
    cachedRecursive = recorder.endRecording();

    drawRecursively = (Canvas canvas) {
      canvas.drawPicture(cachedRecursive);
    };
  }
  //#endregion

  /// draw what is need for only the step
  void Function(Canvas) get draw;

  /// `this` has to stay in pastSteps, draw all steps behind `this` in past steps as well
  late void Function(Canvas) drawRecursively = drawRecursivelyFreshly;

  void drawRecursivelyFreshly(Canvas canvas) {
    if (id > 0) {
      DrawManager.inst.pastSteps[id - 1].drawRecursively(canvas);
    }

    draw(canvas);
  }

  // void _drawTemp(Canvas canvas) {
  //   canvas.drawPicture(temp!);
  // }

  // void Function(Canvas) get drawFresh => _drawFresh;
  // void _drawFresh(Canvas canvas) {
  //   if (id > 0) {
  //     DrawManager.inst.pastSteps[id - 1].draw(canvas);
  //   }

  //   drawAddon(canvas);
  // }

  /// only Fill step can use this
  // switchToTemp() {
  //   var pictureCanvas = Canvas(recorder);

  //   drawFresh(pictureCanvas);

  //   temp = recorder.endRecording();

  //   draw = _drawTemp;
  // }

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

abstract class GestureDrawStep extends DrawStep {
  GestureDrawStep({required super.id});

  void Function(Offset point) get onDown;
  void Function(Offset point) get onUpdate;
  bool get onEnd;

  void changeColor() {}

  /// only Brush step use this
  void changeStrokeSize() {}

  /// Can't use before the step is pushed into the list
  DrawStep get prevStep => DrawManager.inst.pastSteps[id - 1];
}
