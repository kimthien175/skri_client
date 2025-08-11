import 'package:flutter/material.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/step/step.dart';

mixin PlainDrawStep on DrawStep {
  void track() {
    prevPlainStep = PlainDrawStep.latestStep;
    PlainDrawStep.latestStep = this;
  }

  PlainDrawStep? prevPlainStep;

  static PlainDrawStep? latestStep;

  @override
  void unlink() {
    PlainDrawStep.latestStep = prevPlainStep;
    super.unlink();
  }

  Color get color;
}
