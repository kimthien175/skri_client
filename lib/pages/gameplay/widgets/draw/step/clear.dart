import 'package:flutter/material.dart';

import 'plain.dart';
import 'step.dart';

class ClearStep extends DrawStep with PlainDrawStep {
  @override
  void Function(Canvas) get drawBackward => (_) {};

  /// considerd white for later fullfill step can check this
  @override
  Color get color => Colors.white;

  @override
  String get type => TYPE;
  // ignore: constant_identifier_names
  static const String TYPE = 'clear';

  @override
  Map<String, dynamic> get toPrivateJSON => {};
}
