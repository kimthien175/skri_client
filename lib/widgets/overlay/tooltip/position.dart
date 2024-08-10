import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum GameTooltipBackgroundColor {
  notify(),
  warining(value: Color.fromRGBO(229, 115, 115, 1.0)),
  input(value: Color(0xffffffff));

  const GameTooltipBackgroundColor({this.value = const Color.fromRGBO(69, 113, 255, 1.0)});
  final Color value;
}

abstract class GameTooltipPosition {
  const factory GameTooltipPosition.centerLeft({GameTooltipBackgroundColor backgroundColor}) =
      _CenterLeft;
  const factory GameTooltipPosition.centerRight({GameTooltipBackgroundColor backgroundColor}) =
      _CenterRight;
  const factory GameTooltipPosition.centerTop({GameTooltipBackgroundColor backgroundColor}) =
      _CenterTop;
  const factory GameTooltipPosition.centerBottom({GameTooltipBackgroundColor backgroundColor}) =
      _CenterBottom;
  const GameTooltipPosition({this.backgroundColor = GameTooltipBackgroundColor.notify});
  final GameTooltipBackgroundColor backgroundColor;

  Widget build(
      {required Widget child,
      required RenderBox originalBox,
      required double scale,
      Animation<double>? scaleAnimation}) {
    var newChild = _build(child);

    if (scaleAnimation != null) {
      newChild =
          ScaleTransition(alignment: relativeAlignment, scale: scaleAnimation, child: newChild);
    }

    return _wrapWithZone(
        Align(
            alignment: relativeAlignment,
            child: scale == 1.0
                ? newChild
                : Transform.scale(
                    scale: scale,
                    alignment: relativeAlignment,
                    child: newChild,
                  )),
        originalBox.localToGlobal(Offset.zero),
        originalBox.size * scale);
  }

  Widget _wrapWithZone(Widget aligned, Offset offset, Size size);

  Widget _build(Widget rawChild);

  Container _wrapWithContainer(Widget child) => Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
          color: backgroundColor.value, borderRadius: const BorderRadius.all(Radius.circular(3))),
      child: child);

  Widget get arrow => ClipPath(
      clipper: _ArrowClip(arrowPath),
      child: Container(height: height, width: width, color: backgroundColor.value));

  double get height;
  double get width;
  Alignment get relativeAlignment;
  Path Function(Size size) get arrowPath;
}

class _CenterLeft extends GameTooltipPosition {
  const _CenterLeft({super.backgroundColor});
  @override
  Widget _build(Widget rawChild) =>
      Row(mainAxisSize: MainAxisSize.min, children: [_wrapWithContainer(rawChild), arrow]);

  @override
  Path Function(Size size) get arrowPath => (size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, size.height / 2)
    ..lineTo(0, size.height);

  @override
  double get height => 20;

  @override
  double get width => 10;

  @override
  Alignment get relativeAlignment => Alignment.centerRight;

  @override
  Widget _wrapWithZone(Widget aligned, Offset offset, Size size) =>
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

class _CenterTop extends GameTooltipPosition {
  const _CenterTop({super.backgroundColor});
  @override
  Path Function(Size size) get arrowPath => (size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width / 2, size.height);

  @override
  double get height => 10;

  @override
  double get width => 20;

  @override
  Widget _build(Widget rawChild) =>
      Column(mainAxisSize: MainAxisSize.min, children: [_wrapWithContainer(rawChild), arrow]);

  @override
  Alignment get relativeAlignment => Alignment.bottomCenter;

  @override
  Widget _wrapWithZone(Widget aligned, Offset offset, Size size) =>
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

class _CenterRight extends GameTooltipPosition {
  const _CenterRight({super.backgroundColor});
  @override
  Path Function(Size size) get arrowPath => (size) => Path()
    ..moveTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height / 2);

  @override
  double get height => 20;

  @override
  double get width => 10;

  @override
  Widget _build(Widget rawChild) =>
      Row(mainAxisSize: MainAxisSize.min, children: [arrow, _wrapWithContainer(rawChild)]);

  @override
  Alignment get relativeAlignment => Alignment.centerLeft;

  @override
  Widget _wrapWithZone(Widget aligned, Offset offset, Size size) =>
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

class _CenterBottom extends GameTooltipPosition {
  const _CenterBottom({super.backgroundColor});
  @override
  Path Function(Size size) get arrowPath => (size) => Path()
    ..moveTo(0, size.height)
    ..lineTo(size.width, size.height)
    ..lineTo(size.width / 2, 0);

  @override
  double get height => 10;

  @override
  double get width => 20;

  @override
  Widget _build(Widget rawChild) =>
      Column(mainAxisSize: MainAxisSize.min, children: [arrow, _wrapWithContainer(rawChild)]);

  @override
  Alignment get relativeAlignment => Alignment.topCenter;

  @override
  Widget _wrapWithZone(Widget aligned, Offset offset, Size size) =>
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

class _ArrowClip extends CustomClipper<Path> {
  _ArrowClip(this._path);
  final Path Function(Size) _path;
  @override
  Path getClip(Size size) => _path(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
