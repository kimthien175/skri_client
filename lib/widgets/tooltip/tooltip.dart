library game_tooltip;

export 'position.dart';

import 'package:skribbl_client/widgets/dialog.dart';
import 'package:flutter/material.dart';

import 'position.dart';

// ignore: must_be_immutable
class GameTooltip extends StatelessWidget with GameOverlay {
  GameTooltip(
      {super.key,
      required this.tooltip,
      GameTooltipPosition? position,
      double Function()? scale,
      this.anchorKey,
      this.controller}) {
    _scale = scale ?? () => 1.0;
    this.position = position ?? const GameTooltipPositionTop();
  }

  final String Function() tooltip;
  late final GameTooltipPosition position;
  late final double Function() _scale;
  final GlobalKey? anchorKey;
  final AnimationController? controller;

  RenderBox get originalBox => anchorKey!.currentContext!.findRenderObject() as RenderBox;
  Animation<double> get scaleAnimation => controller!.drive(Tween<double>(begin: 0, end: 1));

  showWithController() {
    show();
    controller!.forward();
  }

  hideWithController() {
    controller!.reverse().then((_) => hide());
  }

  @override
  Widget build(BuildContext context) => position.build(
      scaleAnimation: scaleAnimation,
      originalBox: originalBox,
      scale: _scale(),
      child: DefaultTextStyle(
        style: const TextStyle(
            color: Color.fromRGBO(240, 240, 240, 1),
            fontWeight: FontWeight.w700,
            fontSize: 13.0,
            fontFamily: 'Nunito'),
        child: Text(tooltip()),
      ));
}
