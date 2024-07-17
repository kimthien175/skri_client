import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';

import '../../../utils/utils.dart';

class AnimatedButtonBackgroundColorDecorator extends AnimatedButtonDecorator {
  const AnimatedButtonBackgroundColorDecorator(
      {this.height,
      this.width,
      this.borderRadius = GlobalStyles.borderRadius,
      this.color = GlobalStyles.colorPanelButton,
      this.hoverColor = GlobalStyles.colorPanelButtonHover});

  final double? height;
  final double? width;
  final BorderRadius borderRadius;

  final Color color;
  final Color hoverColor;
  @override
  void decorate(AnimatedButtonState state) {
    state.child = _BackgroundColorTransition(
        listenable: state.curvedAnimation.drive(ColorTween(begin: color, end: hoverColor)),
        height: height,
        width: width,
        borderRadius: borderRadius,
        child: state.child);
  }
}

class _BackgroundColorTransition extends AnimatedWidget {
  const _BackgroundColorTransition(
      {required this.child,
      this.height,
      this.width,
      required this.borderRadius,
      required super.listenable});
  final double? height;
  final double? width;
  final BorderRadius borderRadius;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: (listenable as Animation).value, borderRadius: borderRadius),
        child: DefaultTextStyle(
            style: const TextStyle(
                shadows: [GlobalStyles.textShadow],
                fontFamily: 'Nunito-var',
                fontVariations: [FontVariation.weight(800)],
                color: PanelStyles.textColor,
                fontSize: 19.5),
            child: child));
  }
}
