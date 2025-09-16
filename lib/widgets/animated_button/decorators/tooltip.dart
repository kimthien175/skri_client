library;

export '../../overlay/tooltip/position.dart';

import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';
import 'package:skribbl_client/widgets/overlay/newgame_tooltip.dart';

// ignore: must_be_immutable
class AnimatedButtonTooltipDecorator implements AnimatedButtonDecorator {
  AnimatedButtonTooltipDecorator(
      {required this.child, this.position = const NewGameTooltipPosition.centerTop()});

  _Tooltip? _tooltip;

  final Widget child;
  final NewGameTooltipPosition position;

  @override
  void decorate(AnimatedButtonState state) {
    _tooltip = _Tooltip(child: child, position: position, state: state);

    state.child = _tooltip!.attach(state.child);

    state.onEnterCallbacks.add(_tooltip!.show);

    state.onReverseEnd.add(_tooltip!.hideInstancely);
  }

  @override
  void clean() {
    _tooltip?.dispose();
  }
}

class _Tooltip extends NewGameTooltipController {
  _Tooltip({required super.child, required this.state, required super.position})
      : super(controller: state.controller);
  final AnimatedButtonState state;
  @override
  Animation<double> get scaleAnimation => state.curvedAnimation;
}
