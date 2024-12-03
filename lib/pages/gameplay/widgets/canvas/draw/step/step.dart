import 'dart:ui';

import '../manager.dart';

abstract class DrawStep {
  DrawStep({required this.id}) {
    draw = drawFresh;
  }

  int id;
  Picture? temp;

  final recorder = PictureRecorder();

  /// addOn, no previous drawing
  void drawAddon(Canvas canvas){}
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

abstract class GestureDrawStep extends DrawStep {
  GestureDrawStep({required super.id});

  late void Function(Offset point) onDown;
  late void Function(Offset point) onUpdate;
  late bool Function() onEnd;

  void changeColor() {}
  void changeStrokeSize() {}

  /// Can't use before the step is pushed into the list
  DrawStep get prevStep => DrawManager.inst.pastSteps[id - 1];
}
