import 'package:flutter/material.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/step/plain.dart';

import 'step.dart';

class ClearStep extends DrawStep with PlainDrawStep {
  @override
  void Function(Canvas) get drawBackward => (_) {};

  /// considerd white for later fullfill step can check this
  @override
  Color get color => Colors.white;
}
