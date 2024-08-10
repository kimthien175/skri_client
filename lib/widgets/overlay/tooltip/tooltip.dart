library game_tooltip;

export 'position.dart';

import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';

import 'position.dart';

class GameTooltip extends OverlayController {
  /// If `anchorKey` or `controller` are not provided, override getter `finalAnchorKey` or `finalController`
  GameTooltip(
      {required this.tooltip,
      this.position = const GameTooltipPosition.centerTop(),
      this.scale = GameTooltip._defaultScaler,
      this.anchorKey,
      this.controller})
      : super(() => const _Tooltip());

  static double _defaultScaler() => 1.0;

  final String Function() tooltip;
  final GameTooltipPosition position;
  final double Function() scale;

  final GlobalKey? anchorKey;
  GlobalKey get finalAnchorKey => anchorKey!;

  final AnimationController? controller;
  AnimationController get finalController => controller!;

  RenderBox get originalBox => finalAnchorKey.currentContext!.findRenderObject() as RenderBox;
  Animation<double> get scaleAnimation => finalController.drive(Tween<double>(begin: 0, end: 1));

  @override
  bool show() {
    if (super.show()) {
      finalController.forward();
    }
    return false;
  }

  @override
  void hide() {
    finalController.reverse().then((_) => super.hide());
  }

  Widget build(BuildContext context) => position.build(
      scaleAnimation: scaleAnimation,
      originalBox: originalBox,
      scale: scale(),
      child: DefaultTextStyle(
        style: const TextStyle(
            color: Color.fromRGBO(240, 240, 240, 1),
            fontWeight: FontWeight.w700,
            fontSize: 13.0,
            fontFamily: 'Nunito'),
        child: Text(tooltip()),
      ));
}

class _Tooltip extends StatelessWidget with OverlayWidgetMixin<GameTooltip> {
  const _Tooltip();

  @override
  Widget build(BuildContext context) => controller.build(context);
}
