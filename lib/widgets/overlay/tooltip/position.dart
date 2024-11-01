import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/overlay/position.dart';

enum GameTooltipBackgroundColor {
  notify(),
  warining(value: Color.fromRGBO(229, 115, 115, 1.0)),
  input(value: Color(0xffffffff));

  const GameTooltipBackgroundColor({this.value = const Color.fromRGBO(69, 113, 255, 1.0)});
  final Color value;
}

abstract class GameTooltipPosition extends OverlayWidgetPosition {
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

  Widget buildAnimation(
      {required Widget child,
      required RenderBox originalBox,
      required double scale,
      required Animation<double> scaleAnimation}) {
    var newChild =
        ScaleTransition(alignment: relativeAlignment, scale: scaleAnimation, child: _build(child));
    return super.build(child: newChild, originalBox: originalBox, scale: scale);
  }

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

  Path Function(Size size) get arrowPath;
}

class _CenterLeft extends GameTooltipPosition with CenterLeftMixin {
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
}

class _CenterTop extends GameTooltipPosition with CenterTopMixin {
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
}

class _CenterRight extends GameTooltipPosition with CenterRightMixin {
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
}

class _CenterBottom extends GameTooltipPosition with CenterBottomMixin {
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
}

class _ArrowClip extends CustomClipper<Path> {
  _ArrowClip(this._path);
  final Path Function(Size) _path;
  @override
  Path getClip(Size size) => _path(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
