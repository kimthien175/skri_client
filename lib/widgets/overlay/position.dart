import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class OverlayWidgetPosition {
  const factory OverlayWidgetPosition.centerLeft() = OverlayWidgetPositionCenterLeft;
  const factory OverlayWidgetPosition.centerTop() = OverlayWidgetPositionCenterTop;
  const factory OverlayWidgetPosition.centerRight() = OverlayWidgetPositionCenterRight;
  const factory OverlayWidgetPosition.centerBotttom() = OverlayWidgetPositionCenterBottom;
  const factory OverlayWidgetPosition.leftBottom() = OverlayWidgetPositionLeftBottom;
  const factory OverlayWidgetPosition.innerTopRight() = OverlayWidgetPositionInnerTopRight;
  const factory OverlayWidgetPosition.innerTopLeft() = OverlayWidgetPositionInnerTopLeft;

  const OverlayWidgetPosition();
  Widget wrapWithZone(Widget aligned, Offset offset, Size size);

  Alignment get relativeAlignment;

  Widget build({required Widget child, required RenderBox originalBox, required double scale}) =>
      wrapWithZone(
          Align(
              alignment: relativeAlignment,
              child: scale == 1.0
                  ? child
                  : Transform.scale(
                      scale: scale,
                      alignment: relativeAlignment,
                      child: child,
                    )),
          originalBox.localToGlobal(Offset.zero),
          originalBox.size * scale);
}

mixin CenterLeftMixin on OverlayWidgetPosition {
  @override
  Alignment get relativeAlignment => Alignment.centerRight;

  @override
  Widget wrapWithZone(Widget aligned, Offset offset, Size size) =>
      // knowing the button stay on the top half or bottom half
      offset.dy + size.height / 2 <= Get.height / 2
          ?
          // top half
          Positioned(
              top: 0,
              left: 0,
              child:
                  SizedBox(width: offset.dx, height: offset.dy * 2 + size.height, child: aligned),
            )
          :
          // bottom half
          Positioned(
              left: 0,
              bottom: 0,
              child: SizedBox(
                  width: offset.dx,
                  height: (Get.height - offset.dy) * 2 - size.height,
                  child: aligned));
}

mixin CenterTopMixin on OverlayWidgetPosition {
  @override
  Alignment get relativeAlignment => Alignment.bottomCenter;
  @override
  Widget wrapWithZone(Widget aligned, Offset offset, Size size) =>
      // know left half or right half
      offset.dx + size.width / 2 <= Get.width / 2
          ?
          // left half
          Positioned(
              top: 0,
              left: 0,
              child: SizedBox(width: offset.dx * 2 + size.width, height: offset.dy, child: aligned))
          :
          // right half
          Positioned(
              top: 0,
              right: 0,
              child: SizedBox(
                  width: (Get.width - offset.dx) * 2 - size.width,
                  height: offset.dy,
                  child: aligned));
}

mixin CenterRightMixin on OverlayWidgetPosition {
  @override
  Alignment get relativeAlignment => Alignment.centerLeft;
  @override
  Widget wrapWithZone(Widget aligned, Offset offset, Size size) =>
      offset.dy + size.height / 2 <= Get.height / 2
          ? Positioned(
              top: 0,
              right: 0,
              child: SizedBox(
                  height: offset.dy * 2 + size.height,
                  width: Get.width - offset.dx - size.width,
                  child: aligned))
          : Positioned(
              bottom: 0,
              right: 0,
              child: SizedBox(
                  height: (Get.height - offset.dy) * 2 - size.height,
                  width: Get.width - offset.dx - size.width,
                  child: aligned));
}

mixin CenterBottomMixin on OverlayWidgetPosition {
  @override
  Alignment get relativeAlignment => Alignment.topCenter;
  @override
  Widget wrapWithZone(Widget aligned, Offset offset, Size size) =>
      offset.dx + size.width / 2 <= Get.width / 2
          ? Positioned(
              left: 0,
              bottom: 0,
              child: SizedBox(
                  width: offset.dx * 2 + size.width,
                  height: Get.height - offset.dy - size.height,
                  child: aligned))
          : Positioned(
              right: 0,
              bottom: 0,
              child: SizedBox(
                  width: (Get.width - offset.dx) * 2 - size.width,
                  height: Get.height - offset.dy - size.height,
                  child: aligned));
}

mixin LeftBottomMixin on OverlayWidgetPosition {
  @override
  Alignment get relativeAlignment => throw UnimplementedError();

  @override
  Widget wrapWithZone(Widget aligned, Offset offset, Size size) => throw UnimplementedError();

  @override
  Widget build({required Widget child, required RenderBox originalBox, required double scale}) {
    var coord = originalBox.localToGlobal(Offset.zero);
    return Positioned(left: coord.dx, top: coord.dy + originalBox.size.height, child: child);
  }
}

class OverlayWidgetPositionCenterLeft extends OverlayWidgetPosition with CenterLeftMixin {
  const OverlayWidgetPositionCenterLeft();
}

class OverlayWidgetPositionCenterTop extends OverlayWidgetPosition with CenterTopMixin {
  const OverlayWidgetPositionCenterTop();
}

class OverlayWidgetPositionCenterRight extends OverlayWidgetPosition with CenterRightMixin {
  const OverlayWidgetPositionCenterRight();
}

class OverlayWidgetPositionCenterBottom extends OverlayWidgetPosition with CenterBottomMixin {
  const OverlayWidgetPositionCenterBottom();
}

class OverlayWidgetPositionLeftBottom extends OverlayWidgetPosition with LeftBottomMixin {
  const OverlayWidgetPositionLeftBottom();
}

class OverlayWidgetPositionInnerTopRight extends OverlayWidgetPosition {
  const OverlayWidgetPositionInnerTopRight();
  @override
  Widget build({required Widget child, required RenderBox originalBox, required double scale}) {
    var coord = originalBox.localToGlobal(Offset.zero);
    return Positioned(
        top: coord.dy, right: Get.width - coord.dx - originalBox.size.width, child: child);
  }

  @override
  Alignment get relativeAlignment => throw UnimplementedError();

  @override
  Widget wrapWithZone(Widget aligned, Offset offset, Size size) {
    throw UnimplementedError();
  }
}

class OverlayWidgetPositionInnerTopLeft extends OverlayWidgetPosition {
  const OverlayWidgetPositionInnerTopLeft();
  @override
  Widget build({required Widget child, required RenderBox originalBox, required double scale}) {
    var coord = originalBox.localToGlobal(Offset.zero);
    //print('top left');
    //print(coord);
    return Positioned(top: coord.dy, left: coord.dx, child: child);
  }

  @override
  Alignment get relativeAlignment => throw UnimplementedError();

  @override
  Widget wrapWithZone(Widget aligned, Offset offset, Size size) => throw UnimplementedError();
}
