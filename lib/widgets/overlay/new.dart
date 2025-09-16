import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';

class NewTooltipController<P extends NewOverlayPosition> extends OverlayController {
  NewTooltipController({required this.position, super.permanent, required this.child});

  final P position;

  //final GlobalKey anchorKey = GlobalKey();
  final LayerLink link = LayerLink();

  final Widget child;

  @override
  Widget widgetBuilder() => const _NewPositionedOverlayWidget();

  Widget attach(Widget child) => CompositedTransformTarget(
      link: link,
      // key: controller.anchorKey,
      child: child);
}

class _NewPositionedOverlayWidget extends StatelessWidget {
  const _NewPositionedOverlayWidget();

  @override
  Widget build(BuildContext context) {
    var controller = OverlayWidget.of<NewTooltipController>(context);

    var child = controller.child;

    var scale = OverlayController.scale(context);
    if (scale != 1.0) {
      child = Transform.scale(
          scale: scale, alignment: controller.position.scaleAlignment, child: child);
    }

    //var screenSize = MediaQuery.of(context).size;

    return CompositedTransformFollower(
        link: controller.link,
        showWhenUnlinked: false,
        //offset: Offset(-100, 100),
        //followerAnchor: Alignment.centerRight,
        targetAnchor: controller.position.targetAnchor,
        followerAnchor: controller.position.followerAnchor,
        child: DefaultTextStyle(
            style: const TextStyle(
                color: Color.fromRGBO(240, 240, 240, 1),
                fontVariations: [FontVariation.weight(700)],
                fontSize: 13.0,
                fontFamily: 'Nunito-var'),
            child: child));
  }
}

abstract class NewOverlayPosition {
  const factory NewOverlayPosition.centerLeft() = _CenterLeft;
  const factory NewOverlayPosition.centerRight() = _CenterRight;
  const factory NewOverlayPosition.centerTop() = _CenterTop;
  const factory NewOverlayPosition.centerBottom() = _CenterBottom;

  const NewOverlayPosition();
  Alignment get targetAnchor;
  Alignment get followerAnchor;

  Alignment get scaleAlignment;
}

mixin PositionedOverlayCenterLeftMixin on NewOverlayPosition {
  @override
  Alignment get followerAnchor => Alignment.centerRight;

  @override
  Alignment get targetAnchor => Alignment.centerLeft;

  @override
  Alignment get scaleAlignment => Alignment.centerRight;
}

class _CenterLeft extends NewOverlayPosition with PositionedOverlayCenterLeftMixin {
  const _CenterLeft();
}

mixin PositionedOverlayCenterRightMixin on NewOverlayPosition {
  @override
  Alignment get followerAnchor => Alignment.centerLeft;

  @override
  Alignment get targetAnchor => Alignment.centerRight;

  @override
  Alignment get scaleAlignment => Alignment.centerLeft;
}

class _CenterRight extends NewOverlayPosition with PositionedOverlayCenterRightMixin {
  const _CenterRight();
}

mixin PositionedOverlayCenterTopMixin on NewOverlayPosition {
  @override
  Alignment get followerAnchor => Alignment.bottomCenter;

  @override
  Alignment get targetAnchor => Alignment.topCenter;

  @override
  Alignment get scaleAlignment => Alignment.bottomCenter;
}

class _CenterTop extends NewOverlayPosition with PositionedOverlayCenterTopMixin {
  const _CenterTop();
}

mixin PositionedOverlayCenterBottomMixin on NewOverlayPosition {
  @override
  Alignment get followerAnchor => Alignment.topCenter;

  @override
  Alignment get targetAnchor => Alignment.bottomCenter;

  @override
  Alignment get scaleAlignment => Alignment.topCenter;
}

class _CenterBottom extends NewOverlayPosition with PositionedOverlayCenterBottomMixin {
  const _CenterBottom();
}
