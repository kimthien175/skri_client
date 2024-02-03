import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../manager.dart';
import 'clear.dart';
import 'flood_fill.dart';
import 'step.dart';

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

      if (preStep is ClearStep) {
        fillWholeScreen = true;
        return true;
      }

      if (preStep is FillStep && preStep.fillWholeScreen) {
        if (preStep._color == _color) return false;
        fillWholeScreen = true;
        return true;
      }

      return true;
    } else {
      fillWholeScreen = true;
    }

    return true;
  }

  bool fillWholeScreen = false;

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
    if (fillWholeScreen) {
      canvas.drawColor(_color, BlendMode.src);
      return;
    }

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

  bool isAddedToQueue = false;

  DrawStep get prevStep => DrawManager.inst.pastSteps[id - 1];

  static Queue<FillStep> fillZoneQueue = Queue();

  /// for fill zone obviouslly, compile temp for this and continue the queue
  Future<void> compileTemp() async {

    // incase prevstep is brush step or other step
    if (prevStep.temp == null) {
      await prevStep.switchToTemp();
    }

    compute(_compileTemp, {
      'prevTemp': prevStep.temp,
      'width': DrawManager.width,
      'height': DrawManager.height,
      'point': _point,
      'color': _color
    }).then((value) {
      fillZoneQueue.removeFirst();

      // assign result
      byteList = value.byteList;
      temp = value.picture;

      // switch to draw temp
      draw = drawTemp;

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

  FutureOr<CompiledTempResult> _compileTemp(Map<String, dynamic> isolatedMsg) async {
    var recorder = PictureRecorder();
    var pictureCanvas = Canvas(recorder);

    var floodfiller = await FloodFiller.init(
        image: await (isolatedMsg['prevTemp'] as Picture)
            .toImage(isolatedMsg['width'], isolatedMsg['height']),
        point: isolatedMsg['point'],
        fillColor: isolatedMsg['color']);

    var byteList = await floodfiller.prepareAndFill();

    var codec = await instantiateImageCodec(
        byteList); //, targetWidth: decodedImage.width, targetHeight: height)

    var frameInfo = await codec.getNextFrame();

    pictureCanvas.drawImage(frameInfo.image, const Offset(0, 0), Paint());

    return CompiledTempResult(byteList, recorder.endRecording());
  }
}

class CompiledTempResult {
  CompiledTempResult(this.byteList, this.picture);
  Uint8List byteList;
  Picture picture;
}
