library;

import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/widgets.dart';

class AnimatedButtonTooltipDecorator implements AnimatedButtonDecorator {
  AnimatedButtonTooltipDecorator({
    required this.tooltip,
    this.position = const GameTooltipPosition.centerTop(),
  });

  late final _Tooltip _tooltip;

  final Widget tooltip;
  final GameTooltipPosition position;

  @override
  void decorate(AnimatedButtonState state) {
    _tooltip = _Tooltip(tooltip: tooltip, position: position, state: state);

    state.child = _tooltip.attach(state.child);

    state.onEnterCallbacks.add(_tooltip.show);

    state.onReverseEnd.add(_tooltip.hideInstancely);
  }

  @override
  void clean() {
    _tooltip.dispose();
  }
}

class _Tooltip extends GameTooltipController {
  _Tooltip({required super.tooltip, required this.state, required super.position})
    : super(controller: state.controller);
  final AnimatedButtonState state;
  @override
  Animation<double> get scaleAnimation => state.curvedAnimation;
}
