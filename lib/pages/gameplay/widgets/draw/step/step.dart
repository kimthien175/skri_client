import 'dart:ui';

import '../manager.dart';

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

  /// addOn, no previous drawing
  void drawAddon(Canvas canvas);
  void drawFull(Canvas canvas) {
    // draw temp of previous node
    if (id > 0) {
      DrawManager.inst.pastSteps[id - 1].drawFull(canvas);
    }

    drawAddon(canvas);
  }

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
