import 'package:skribbl_client/widgets/animated_button/builder.dart';
import 'package:skribbl_client/widgets/animated_button/decorator.dart';
import 'package:skribbl_client/widgets/animated_button/decorators/tooltip/position.dart';
import 'package:skribbl_client/widgets/dialog.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AnimatedButtonTooltipDecorator extends StatelessWidget
    with GameOverlay
    implements AnimatedButtonDecorator {
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

  AnimatedButtonBuilder? _builder;

  @override
  void decorate(AnimatedButtonBuilder builder) {
    _builder = builder;

    builder.onEnterCallbacks.add((e) {
      show();
      position.controller.animController.forward();
    });

    builder.onExitCallbacks.add((e) {
      position.controller.animController.reverse().then((_) {
        hide();
      });
    });
  }

  @override
  void Function() get clean => position.clean;

  @override
  Widget build(BuildContext context) {
    return position.build(
      originalBox: _builder!.buttonKey.currentContext!.findRenderObject() as RenderBox,
      scale: _scale(),
      child: DefaultTextStyle(
        style: const TextStyle(
            color: Color.fromRGBO(240, 240, 240, 1),
            fontWeight: FontWeight.w700,
            fontSize: 13.0,
            fontFamily: 'Nunito'),
        child: Text(
          tooltip,
        ),
      ),
    );
  }
}
