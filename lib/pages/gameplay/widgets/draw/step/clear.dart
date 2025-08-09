import 'dart:ui';

import 'step.dart';

class ClearStep extends DrawStep {
  ClearStep({required super.id});

  @override
  void Function(Canvas) get draw => (_) {};

  @override
  void Function(Canvas canvas) get drawRecursively => (_) {};
}
