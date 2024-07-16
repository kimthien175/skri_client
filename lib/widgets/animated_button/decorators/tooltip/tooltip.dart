library animated_button_tooltip;

export 'position.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';
import 'package:skribbl_client/widgets/dialog.dart';

// ignore: must_be_immutable
class AnimatedButtonTooltipDecorator extends StatelessWidget
    with GameOverlay
    implements AnimatedButtonDecorator {
  //
  /// `tooltip` is raw text, no `.tr`, the widget will translate it <br>
  /// `position` is top for default
  AnimatedButtonTooltipDecorator(
      {super.key,
      required this.tooltip,
      AnimatedButtonTooltipPosition? position,
      double Function()? scale}) {
    _scale = scale ?? () => 1.0;
    this.position = position ?? TooltipPositionTop();
  }

  final String tooltip;
  late final AnimatedButtonTooltipPosition position;
  late final double Function() _scale;

  static Color tooltipBackgroundColor = const Color.fromRGBO(69, 113, 255, 1.0);

  AnimatedButtonState? _state;

  @override
  void decorate(AnimatedButtonState state) {
    _state = state;

    state.onEnterCallbacks.add((e) {
      show();
    });

    state.onReverseEnd.add(() {
      hide();
    });
  }

  @override
  void clean() {}

  @override
  Widget build(BuildContext context) => position.build(
        scaleAnimation: _state!.curvedAnimation,
        originalBox: _state!.buttonKey.currentContext!.findRenderObject() as RenderBox,
        scale: _scale(),
        child: DefaultTextStyle(
          style: const TextStyle(
              color: Color.fromRGBO(240, 240, 240, 1),
              fontWeight: FontWeight.w700,
              fontSize: 13.0,
              fontFamily: 'Nunito'),
          child: Text(tooltip.tr),
        ),
      );
}
