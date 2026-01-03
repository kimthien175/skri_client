library;

import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/widgets.dart';

class AnimatedButtonTooltipDecorator implements AnimatedButtonDecorator {
  const AnimatedButtonTooltipDecorator({
    required this.tooltip,
    this.position = const GameTooltipPosition.centerTop(),
  });

  final Widget tooltip;
  final GameTooltipPosition position;

  @override
  void decorate(AnimatedButtonState state) {
    final tooltipController = _Tooltip(tooltip: tooltip, position: position, state: state);

    state.child = tooltipController.attach(state.child);

    state.onEnterCallbacks.add(tooltipController.show);

    state.onReverseEnd.add(tooltipController.hideInstancely);
  }

  @override
  void clean() {
    // _tooltip is disposed auto
  }
}

class _Tooltip extends GameTooltipController {
  _Tooltip({required super.tooltip, required this.state, required super.position})
    : super(controller: state.controller);
  final AnimatedButtonState state;
  @override
  Animation<double> get scaleAnimation => state.curvedAnimation;
}
