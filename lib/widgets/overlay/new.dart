import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';

class NewTooltipController<P extends NewTooltipPosition> extends OverlayController {
  NewTooltipController(
      {required this.position,
      super.permanent,
      required Widget tooltip,
      this.tapOutsideToClose = true}) {
    this.tooltip = Align(alignment: position.followerAnchor, child: tooltip);
  }

  final bool tapOutsideToClose;

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
              fontFamily: 'Nunito-var'),
          child: tooltip));

  Widget attach(Widget anchor) {
    Widget child = CompositedTransformTarget(link: link, child: anchor);

    if (tapOutsideToClose) {
      child = TapRegion(onTapOutside: (_) => hide(), child: child);
    }

    return child;
  }
}

abstract class NewTooltipPosition {
  const factory NewTooltipPosition.centerLeft() = _CenterLeft;
  const factory NewTooltipPosition.centerRight() = _CenterRight;
  const factory NewTooltipPosition.centerTop() = _CenterTop;
  const factory NewTooltipPosition.centerBottom() = _CenterBottom;

  const NewTooltipPosition();
  Alignment get targetAnchor;
  Alignment get followerAnchor;
}

mixin PositionedOverlayCenterLeftMixin on NewTooltipPosition {
  @override
  Alignment get followerAnchor => Alignment.centerRight;

  @override
  Alignment get targetAnchor => Alignment.centerLeft;
}

class _CenterLeft extends NewTooltipPosition with PositionedOverlayCenterLeftMixin {
  const _CenterLeft();
}

mixin PositionedOverlayCenterRightMixin on NewTooltipPosition {
  @override
  Alignment get followerAnchor => Alignment.centerLeft;

  @override
  Alignment get targetAnchor => Alignment.centerRight;
}

class _CenterRight extends NewTooltipPosition with PositionedOverlayCenterRightMixin {
  const _CenterRight();
}

mixin PositionedOverlayCenterTopMixin on NewTooltipPosition {
  @override
  Alignment get followerAnchor => Alignment.bottomCenter;

  @override
  Alignment get targetAnchor => Alignment.topCenter;
}

class _CenterTop extends NewTooltipPosition with PositionedOverlayCenterTopMixin {
  const _CenterTop();
}

mixin PositionedOverlayCenterBottomMixin on NewTooltipPosition {
  @override
  Alignment get followerAnchor => Alignment.topCenter;

  @override
  Alignment get targetAnchor => Alignment.bottomCenter;
}

class _CenterBottom extends NewTooltipPosition with PositionedOverlayCenterBottomMixin {
  const _CenterBottom();
}
