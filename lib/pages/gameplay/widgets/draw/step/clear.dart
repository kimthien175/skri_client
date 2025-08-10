import 'dart:ui';

import 'step.dart';

class ClearStep extends DrawStep {
  ClearStep() {
    _prevClearStep = _latestStep;
    _latestStep = this;
  }

  @override
  void unlink() {
    _latestStep = _prevClearStep;
    super.unlink();
  }

  ClearStep? _prevClearStep;
  ClearStep? get prevClearStep => _prevClearStep;

  static ClearStep? _latestStep;
  static ClearStep? get latestStep => _latestStep;

  @override
  void Function(Canvas) get draw => (_) {};

  @override
  void drawFreshly(Canvas canvas) =>
      throw Exception('I think overriding `draw` would make `drawFreshly` useless');

  @override
  Future<void> buildCache() async {}
}
