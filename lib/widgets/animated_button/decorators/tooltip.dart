library animated_button_tooltip;

export '../../overlay/tooltip/position.dart';

import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';
import 'package:skribbl_client/widgets/overlay/tooltip/tooltip.dart';

// ignore: must_be_immutable
class AnimatedButtonTooltipDecorator implements AnimatedButtonDecorator {
  AnimatedButtonTooltipDecorator(
      {required this.childBuilder,
      this.position = const GameTooltipPosition.centerTop(),
      this.scale = PositionedOverlayController.defaultScaler});

  _Tooltip? _tooltip;

  final Widget Function() childBuilder;
  final GameTooltipPosition position;
  final double Function() scale;

  @override
  void decorate(AnimatedButtonState state) {
    _tooltip = _Tooltip(childBuilder: childBuilder, scale: scale, position: position, state: state);

    state.onEnterCallbacks.add(_tooltip!.show);

    state.onReverseEnd.add(_tooltip!.hide);
  }

  @override
  void clean() {
    _tooltip?.dispose();
  }
}

class _Tooltip extends GameTooltip {
  _Tooltip({required super.childBuilder, required this.state, super.scale, super.position})
      : super(anchorKey: state.buttonKey, controller: state.controller);
  final AnimatedButtonState state;
  @override
  Animation<double> get scaleAnimation => state.curvedAnimation;
}
