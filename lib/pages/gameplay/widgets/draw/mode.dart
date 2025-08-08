import 'package:skribbl_client/pages/gameplay/widgets/draw/step/brush.dart';
import 'package:flutter/material.dart';

import 'step/fill.dart';
import 'step/step.dart';

typedef GestureStepContructor = GestureDrawStep Function({required int id});

abstract class DrawMode {
  GestureStepContructor get step;

  GestureStepContructor get defaultStep;

  MouseCursor get cursor;
}

class BrushMode extends DrawMode {
  @override
  GestureStepContructor get step => BrushStep.init;

  @override
  GestureStepContructor get defaultStep => BrushStep.defaultInit;

  @override
  MouseCursor get cursor => SystemMouseCursors.click;
}

class FillMode extends DrawMode {
  @override
  GestureStepContructor get step => FillStep.init;

  @override
  MouseCursor get cursor => SystemMouseCursors.precise;

  @override
  GestureStepContructor get defaultStep => FillStep.init;
}
