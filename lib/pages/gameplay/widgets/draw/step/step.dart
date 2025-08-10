import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/manager.dart';

abstract class DrawStep {
  late final int id;

  //#region For linked list
  DrawStep? prev;
  DrawStep? next;

  void unlink() {
    prev?.next = next;
    next?.prev = prev;
  }

  /// chain up, set id, return `newStep`
  DrawStep chainUp(DrawStep newStep) {
    next = newStep;

    newStep.prev = this;
    newStep.id = id + 1;

    return newStep;
  }

  //#endregion

  //#region For caching
  late final Picture cache;

  /// use when current draw is fresh,
  /// build cache and change current draw to drawing cache
  Future<void> buildCache() async {
    var recorder = PictureRecorder();
    var canvas = Canvas(recorder);

    // loop from this to last
    draw(canvas);

    cache = recorder.endRecording();

    // switch to draw cache
    draw = _drawCache;
  }
  //#endregion

  /// draw what is need for only the step
  late void Function(Canvas) draw = drawFreshly;

  /// draw from `this` to last tail
  @nonVirtual
  void drawChain(Canvas canvas) {
    draw(canvas);
    next?.drawChain(canvas);
  }

  void drawFreshly(Canvas canvas);

  @nonVirtual
  void _drawCache(Canvas canvas) {
    canvas.drawPicture(cache);
  }

  /// `this` has to stay in pastSteps, draw all steps behind `this` in past steps as well
  // late void Function(Canvas) drawRecursively = drawRecursivelyFreshly;

  // void drawRecursivelyFreshly(Canvas canvas) {
  //   if (id > 0) {
  //     DrawManager.inst.pastSteps[id - 1].drawRecursively(canvas);
  //   }

  //   draw(canvas);
  // }

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
  void Function(Offset point) get onDown;
  void Function(Offset point) get onUpdate;
  bool get onEnd;

  void changeColor() {}

  /// only Brush step use this
  void changeStrokeSize() {}
}
