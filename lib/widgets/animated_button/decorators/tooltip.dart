library animated_button_tooltip;

export '../../tooltip/position.dart';

import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';
import 'package:skribbl_client/widgets/tooltip/tooltip.dart';

// ignore: must_be_immutable
class AnimatedButtonTooltipDecorator extends GameTooltip implements AnimatedButtonDecorator {
  //
  /// `tooltip` is raw text, no `.tr`, the widget will translate it <br>
  /// `position` is top for default
  AnimatedButtonTooltipDecorator({super.key, required super.tooltip, super.position, super.scale});

  AnimatedButtonState? _state;
  @override
  RenderBox get originalBox => _state!.buttonKey.currentContext!.findRenderObject() as RenderBox;
  @override
  Animation<double> get scaleAnimation => _state!.curvedAnimation;

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
