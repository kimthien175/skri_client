import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';

class TooltipController<P extends TooltipPosition> extends OverlayController {
  TooltipController({required this.position, required Widget tooltip}) {
    this.tooltip = Align(alignment: position.followerAnchor, child: tooltip);
  }

  final P position;

  final LayerLink link = LayerLink();

  late final Widget tooltip;

  @override
  Widget widgetBuilder() => CompositedTransformFollower(
    link: link,
    showWhenUnlinked: false,
    targetAnchor: position.targetAnchor,
    followerAnchor: position.followerAnchor,
    child: DefaultTextStyle(
      style: const TextStyle(
        color: Color.fromRGBO(240, 240, 240, 1),
        fontVariations: [FontVariation.weight(700)],
        fontSize: 13.0,
        fontFamily: 'Nunito-var',
      ),
      child: tooltip,
    ),
  );

  Widget attach(Widget anchor) => CompositedTransformTarget(link: link, child: anchor);
}

abstract class TooltipPosition {
  const factory TooltipPosition.centerLeft() = _CenterLeft;
  const factory TooltipPosition.centerRight() = _CenterRight;
  const factory TooltipPosition.centerTop() = _CenterTop;
  const factory TooltipPosition.centerBottom() = _CenterBottom;

  const TooltipPosition();
  Alignment get targetAnchor;
  Alignment get followerAnchor;
}

mixin PositionedOverlayCenterLeftMixin on TooltipPosition {
  @override
  Alignment get followerAnchor => Alignment.centerRight;

  @override
  Alignment get targetAnchor => Alignment.centerLeft;
}

class _CenterLeft extends TooltipPosition with PositionedOverlayCenterLeftMixin {
  const _CenterLeft();
}

mixin PositionedOverlayCenterRightMixin on TooltipPosition {
  @override
  Alignment get followerAnchor => Alignment.centerLeft;

  @override
  Alignment get targetAnchor => Alignment.centerRight;
}

class _CenterRight extends TooltipPosition with PositionedOverlayCenterRightMixin {
  const _CenterRight();
}

mixin PositionedOverlayCenterTopMixin on TooltipPosition {
  @override
  Alignment get followerAnchor => Alignment.bottomCenter;

  @override
  Alignment get targetAnchor => Alignment.topCenter;
}

class _CenterTop extends TooltipPosition with PositionedOverlayCenterTopMixin {
  const _CenterTop();
}

mixin PositionedOverlayCenterBottomMixin on TooltipPosition {
  @override
  Alignment get followerAnchor => Alignment.topCenter;

  @override
  Alignment get targetAnchor => Alignment.bottomCenter;
}

class _CenterBottom extends TooltipPosition with PositionedOverlayCenterBottomMixin {
  const _CenterBottom();
}
