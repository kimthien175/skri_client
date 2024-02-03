import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';

import '../manager.dart';
import 'clear.dart';
import 'flood_fill.dart';
import 'step.dart';

class FillStep extends DrawStep {
  FillStep.init({required super.id}) {
    _drawMain = drawLayzy;
  }

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

      if (preStep is ClearStep) {
        _drawMain = drawFullfillColor;
        return true;
      }

      if (preStep is FillStep && preStep._drawMain == preStep.drawFullfillColor) {
        if (preStep._color == _color) return false;
        _drawMain = drawFullfillColor;
        return true;
      }

      return true;
    } else {
      _drawMain = drawFullfillColor;
    }

    return true;
  }

  //bool fillWholeScreen = false;

  /// Unint8list
  Uint8List? byteList;

  @override
  void drawAddon(Canvas canvas) {}

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

  @override
  void drawFresh(Canvas canvas) {
    _drawMain(canvas);
  }

  late void Function(Canvas) _drawMain;

  void drawFullfillColor(Canvas canvas) {
    canvas.drawColor(_color, BlendMode.src);
  }

  void drawLayzy(Canvas canvas) {
    // draw previous node temp
    prevStep.draw(canvas);

    if (isAddedToQueue) return;

    //#region FILL ZONE
    fillZoneQueue.add(this);
    if (fillZoneQueue.length == 1) {
      compileTemp();
    }
    //#endregion

    isAddedToQueue = true;
  }

  void drawImage(Canvas canvas) {
    canvas.drawImage(result!, const Offset(0, 0), Paint());
  }

  bool isFullfillScreenWithSameColor(Color color) => _drawMain == drawFullfillColor && _color == color;

  bool isAddedToQueue = false;

  static Queue<FillStep> fillZoneQueue = Queue();

  /// for fill zone obviouslly, compile temp for this and continue the queue
  Future<void> compileTemp() async {
    // incase prevstep is brush step or other step
    if (prevStep.temp == null) {
      await prevStep.switchToTemp();
    }

    _compileTemp().then((value) async{
      fillZoneQueue.removeFirst();

      await Future.delayed(const Duration(seconds: 1));
      // assign result
      // byteList = value.byteList;
      // temp = value.picture;
      result = value;

      // switch to draw temp
      _drawMain = drawImage;

      DrawManager.inst.rerenderLastStep();

      // compile next node
      if (fillZoneQueue.isEmpty) return;

      fillZoneQueue.first.compileTemp();
    }).catchError((e) {
      fillZoneQueue.removeFirst();

      // remove this node
      DrawManager.inst.pastSteps.removeAt(id);

      for (int i = id; i < DrawManager.inst.pastSteps.length; i++) {
        DrawManager.inst.pastSteps[i].id--;
      }

      // compile next node
      if (fillZoneQueue.isEmpty) return;

      fillZoneQueue.first.compileTemp();
    });
  }

  Future<Image> _compileTemp() async {
    var img = await prevStep.temp!.toImage(DrawManager.width.toInt(), DrawManager.height.toInt());

    var floodfiller = await FloodFiller.init(image: img, point: _point!, fillColor: _color);

    byteList = floodfiller.prepareAndFill();
    Completer<Image> completer = Completer<Image>();
    decodeImageFromPixels(byteList!, DrawManager.width.toInt(), DrawManager.height.toInt(),
        PixelFormat.rgba8888, completer.complete);

    return completer.future;
  }

  Image? result;
}
