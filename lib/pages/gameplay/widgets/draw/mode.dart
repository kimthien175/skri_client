import 'package:flutter/material.dart';

import 'step.dart';

abstract class DrawMode {
  DrawStep Function({required int id}) get step;

  MouseCursor get cursor;
}

class BrushMode extends DrawMode {
  @override
  DrawStep Function({required int id}) get step => BrushStep.init;
  
  @override
  MouseCursor get cursor => SystemMouseCursors.grab;
}

class FillMode extends DrawMode {
  @override
  DrawStep Function({required int id}) get step => FillStep.init;
  
  @override
  MouseCursor get cursor => SystemMouseCursors.help;
}