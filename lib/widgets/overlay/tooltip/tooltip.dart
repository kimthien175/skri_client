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
  Widget Function() get widgetBuilder => () => const _Tooltip();

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

class _Tooltip extends OverlayChildWidget<GameTooltip> {
  const _Tooltip();
  @override
  Widget build(BuildContext context) {
    var c = controller(context);
    return c.position.buildAnimation(
        scaleAnimation: c.scaleAnimation,
        originalBox: c.originalBox,
        scale: c.scale(),
        child: DefaultTextStyle(
          style: const TextStyle(
              color: Color.fromRGBO(240, 240, 240, 1),
              fontVariations: [FontVariation.weight(700)],
              fontSize: 13.0,
              fontFamily: 'Nunito-var'),
          child: c.childBuilder(),
        ));
  }
}
