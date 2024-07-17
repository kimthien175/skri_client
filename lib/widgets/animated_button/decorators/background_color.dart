import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';

import '../../../utils/utils.dart';

class AnimatedButtonBackgroundColorDecorator extends AnimatedButtonDecorator {
  AnimatedButtonBackgroundColorDecorator(
      {this.height,
      this.width,
      this.borderRadius = GlobalStyles.borderRadius,
      required this.colorTween});
  final double? height;
  final double? width;
  final BorderRadius borderRadius;
  final ColorTween colorTween;
  @override
  void decorate(AnimatedButtonState state) {
    state.child = _BackgroundColorTransition(
        listenable: state.curvedAnimation.drive(colorTween),
        height: height,
        width: width,
        borderRadius: borderRadius,
        child: state.child);
  }
}

class _BackgroundColorTransition extends AnimatedWidget {
  const _BackgroundColorTransition(
      {this.child, this.height, this.width, required this.borderRadius, required super.listenable});
  final double? height;
  final double? width;
  final BorderRadius borderRadius;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: (listenable as Animation).value, borderRadius: borderRadius),
        child: child);
  }
}
