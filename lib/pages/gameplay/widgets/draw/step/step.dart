import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class DrawStep {
  DrawStep();
  late final int id;

  //#region For linked list
  DrawStep? prev;
  DrawStep? next;

  void unlink() {
    prev?.next = next;
    next?.prev = prev;
  }

  //#endregion

  //#region For caching
  Future<bool> buildCache();

  /// for FloodFillStep as next DrawStep to access
  Future<ui.Image> get cache;
  //#endregion

  /// loop to this into previous step, finally draw freshly
  /// expected to be that when previous step have temp or plain draw, the loop would stop
  void Function(Canvas) get drawBackward;

  /// have private child content, don't include `id`, `type`, `prevID`, `nextID`
  Map<String, dynamic> get toPrivateJSON;

  @nonVirtual
  Map<String, dynamic> get toJSON {
    var result = toPrivateJSON;

    result['id'] = id;
    result['type'] = type;
    result['prev_id'] = prev?.id;
    //result['next_id'] = next?.id;

    return result;
  }

  String get type;
  int? performerPrevID;
  //int? performerNextID;

  /// until receiving undo signal
  bool isHardLinkedWithPrev(int newStepId) => prev!.id == performerPrevID && newStepId < id;
}

mixin GestureDrawStep on DrawStep {
  void Function(Offset point) get onDown;
  void Function(Offset point) get onUpdate;
  bool get onEnd;

  void changeColor();

  /// only Brush step use this
  void changeStrokeSize() {}

  void Function(Canvas) get draw;
}
