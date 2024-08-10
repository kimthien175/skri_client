library animated_button_tooltip;

export '../../overlay/tooltip/position.dart';

import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';
import 'package:skribbl_client/widgets/overlay/tooltip/tooltip.dart';

// ignore: must_be_immutable
class AnimatedButtonTooltipDecorator extends GameTooltip implements AnimatedButtonDecorator {
  AnimatedButtonTooltipDecorator({required super.tooltip, super.position, super.scale});

  AnimatedButtonState? _state;

  @override
  Animation<double> get scaleAnimation => _state!.curvedAnimation;

  @override
  GlobalKey<State<StatefulWidget>> get finalAnchorKey => _state!.buttonKey;
  @override
  AnimationController get finalController => _state!.controller;

  @override
  void decorate(AnimatedButtonState state) {
    _state = state;

    state.onEnterCallbacks.add(show);

    state.onReverseEnd.add(hide);
  }

  @override
  void clean() {
    hide();
  }
}
