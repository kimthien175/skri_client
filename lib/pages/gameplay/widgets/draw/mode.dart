import 'package:skribbl_client/pages/gameplay/widgets/draw/step/brush.dart';
import 'package:flutter/material.dart';

import 'step/fill/fill.dart';
import 'step/step.dart';

typedef GestureStepContructor = GestureDrawStep Function();

abstract class DrawMode {
  const factory DrawMode.brush() = BrushMode._init;
  const factory DrawMode.fill() = FillMode._init;

  const DrawMode();

  GestureStepContructor get stepFactory;

  MouseCursor get cursor;
}

class BrushMode extends DrawMode {
  const BrushMode._init();

  @override
  GestureStepContructor get stepFactory => BrushStep.init;

  @override
  MouseCursor get cursor => SystemMouseCursors.click;
}

class FillMode extends DrawMode {
  const FillMode._init();

  @override
  GestureStepContructor get stepFactory => FillStep.init;

  @override
  MouseCursor get cursor => SystemMouseCursors.precise;
}
