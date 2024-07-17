import 'package:flutter/material.dart';

import '../animated_button.dart';

class AnimatedButtonScaleDecorator extends AnimatedButtonDecorator {
  const AnimatedButtonScaleDecorator({this.min = 1.0, this.max = 1.1});

  final double min;
  final double max;

  @override
  void decorate(AnimatedButtonState state) {
    // wrap the widget with ScaleTransition
    state.child = ScaleTransition(
      scale: state.curvedAnimation.drive(Tween<double>(begin: min, end: max)),
      filterQuality: FilterQuality.none,
      child: state.child,
    );
  }
}
