library game_tooltip;

export 'position.dart';
import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';

import 'position.dart';

class GameTooltip extends PositionedOverlayController<GameTooltipPosition> {
  GameTooltip(
      {required super.childBuilder,
      super.position = const GameTooltipPosition.centerTop(),
      super.scale,
      required this.controller,
      required super.anchorKey});

  @override
  Widget Function() get builder => () => const _Tooltip();

  final AnimationController controller;
  Animation<double> get scaleAnimation => controller.drive(Tween<double>(begin: 0, end: 1));

  @override
  Future<bool> show() async {
    if (await super.show()) {
      await controller.forward();
      return true;
    }
    return false;
  }

  @override
  Future<bool> hide() async {
    await controller.reverse();
    return super.hide();
  }
}

class _Tooltip extends StatelessWidget with OverlayWidgetMixin<GameTooltip> {
  const _Tooltip();
  @override
  Widget build(BuildContext context) {
    return controller.position.buildAnimation(
        scaleAnimation: controller.scaleAnimation,
        originalBox: controller.originalBox,
        scale: controller.scale(),
        child: DefaultTextStyle(
          style: const TextStyle(
              color: Color.fromRGBO(240, 240, 240, 1),
              fontWeight: FontWeight.w700,
              fontSize: 13.0,
              fontFamily: 'Nunito'),
          child: controller.childBuilder(controller.tag),
        ));
  }
}
