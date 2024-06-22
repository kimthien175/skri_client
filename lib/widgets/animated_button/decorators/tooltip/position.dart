import 'package:cd_mobile/widgets/animated_button/decorators/tooltip/controller.dart';
import 'package:cd_mobile/widgets/animated_button/decorators/tooltip/tooltip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class AnimatedButtonTooltipPosition {
  final ScaleTooltipController controller = ScaleTooltipController();

  Widget build({required Widget child, required RenderBox originalBox, required double scale}) =>
      _wrapWithZone(_buildWithAlign(child, scale), originalBox.localToGlobal(Offset.zero),
          originalBox.size * scale);

  Widget _wrapWithZone(Widget aligned, Offset offset, Size size);

  Widget _buildWithAlign(Widget child, double scale) {
    // put original child in tooltip 'background', wrap with ScaleTransition
    var newChild = ScaleTransition(
        alignment: relativeAlignment, scale: controller.animation, child: _build(child));
    return Align(
        alignment: relativeAlignment,
        child: scale == 1.0
            ? newChild
            : Transform.scale(
                scale: scale,
                alignment: relativeAlignment,
                child: newChild,
              ));
  }

  Widget _build(Widget rawChild);

  Container _wrapWithContainer(Widget child) => Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
          color: AnimatedButtonTooltipDecorator.tooltipBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(3))),
      child: child);

  Widget get arrow => ClipPath(
      clipper: _ArrowClip(arrowPath),
      child: Container(
          height: height,
          width: width,
          color: AnimatedButtonTooltipDecorator.tooltipBackgroundColor));

  double get height;
  double get width;
  Alignment get relativeAlignment;
  Path Function(Size size) get arrowPath;

  void clean() {
    controller.dispose();
  }
}

class TooltipPositionLeft extends AnimatedButtonTooltipPosition {
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

class TooltipPositionTop extends AnimatedButtonTooltipPosition {
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

class TooltipPositionRight extends AnimatedButtonTooltipPosition {
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

class TooltipPositionBottom extends AnimatedButtonTooltipPosition {
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
