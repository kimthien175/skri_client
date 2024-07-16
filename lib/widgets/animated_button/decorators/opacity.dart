import 'package:flutter/material.dart';
import '../animated_button.dart';

class AnimatedButtonOpacityDecorator extends AnimatedButtonDecorator {
  AnimatedButtonOpacityDecorator({this.minOpacity = 0.5});

  final double minOpacity;

  @override
  void decorate(AnimatedButtonState state) {
    // modify widget: wrap widget with AnimatedOpacity
    state.child = FadeTransition(
        opacity: state.curvedAnimation.drive(Tween(begin: minOpacity, end: 1.0)),
        child: state.child);
  }
}
