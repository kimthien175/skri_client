import 'package:flutter/material.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/step/plain.dart';

import 'step.dart';

class ClearStep extends DrawStep with PlainDrawStep {
  ClearStep() {
    track();
  }

  @override
  void Function(Canvas) get draw =>
      (_) => throw Exception('I think overriding `drawChain` would make `draw` useless');

  @override
  void drawFreshly(Canvas canvas) =>
      throw Exception('I think overriding `draw` would make `drawFreshly` useless');

  @override
  Future<void> buildCache() async {}

  @override
  void drawChain(Canvas canvas) {
    next?.drawChain(canvas);
  }

  /// considerd white for later fullfill step can check this
  @override
  Color get color => Colors.white;
}
