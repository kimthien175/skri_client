import 'dart:ui';

import 'step.dart';

class ClearStep extends DrawStep {
  ClearStep({required super.id});

  @override
  void drawAddon(Canvas canvas) {}

  @override
  void drawFresh(Canvas canvas) {}

  @override
  Future<void> switchToTemp() async {}
}
