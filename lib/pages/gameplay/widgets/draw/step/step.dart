import 'dart:ui';

import '../manager.dart';

abstract class DrawStep {
  DrawStep({required this.id}) {
    draw = drawFresh;
  }

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

  /// Can't use before the step is pushed into the list
  DrawStep get prevStep => DrawManager.inst.pastSteps[id - 1];

  final recorder = PictureRecorder();

  /// addOn, no previous drawing
  void drawAddon(Canvas canvas);
  late void Function(Canvas canvas) draw;

  void drawTemp(Canvas canvas) {
    canvas.drawPicture(temp!);
  }

  void drawFresh(Canvas canvas) {
    if (id > 0) {
      DrawManager.inst.pastSteps[id - 1].draw(canvas);
    }

    drawAddon(canvas);
  }

  Future<void> switchToTemp() async {
    var pictureCanvas = Canvas(recorder);

    drawFresh(pictureCanvas);

    temp = recorder.endRecording();

    draw = drawTemp;
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

  Future<void> emitDownCurrent(Offset point) async {}
  Future<void> emitUpdateCurrent(Offset point) async {}
}
