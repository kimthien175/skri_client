import 'package:cd_mobile/pages/gameplay/widgets/draw/step/brush.dart';
import 'package:flutter/material.dart';

import 'step/fill.dart';
import 'step/step.dart';

abstract class DrawMode {
  GestureDrawStep Function({required int id}) get step;

  GestureDrawStep Function({required int id}) get defaultStep;

  MouseCursor get cursor;
}

class BrushMode extends DrawMode {
  @override
  GestureDrawStep Function({required int id}) get step => BrushStep.init;

  @override
  GestureDrawStep Function({required int id}) get defaultStep => BrushStep.defaultInit;

  @override
  MouseCursor get cursor => SystemMouseCursors.grab;
}

class FillMode extends DrawMode {
  @override
  GestureDrawStep Function({required int id}) get step => FillStep.init;

  @override
  MouseCursor get cursor => SystemMouseCursors.help;

  @override
  GestureDrawStep Function({required int id}) get defaultStep => FillStep.init;
}
