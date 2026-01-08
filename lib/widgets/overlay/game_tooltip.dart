import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:skribbl_client/widgets/widgets.dart';

enum GameTooltipBackgroundColor {
  notify(),
  warining(value: Color.fromRGBO(229, 115, 115, 1.0)),
  input(value: Color(0xffffffff));

  const GameTooltipBackgroundColor({this.value = const Color.fromRGBO(69, 113, 255, 1.0)});
  final Color value;
}

class GameTooltipController extends TooltipController<GameTooltipPosition>
    with GetTickerProviderStateMixin {
  GameTooltipController({
    required super.position,
    required super.tooltip,
    AnimationController? controller,
  }) {
    this.controller =
        controller ?? AnimationController(vsync: this, duration: AnimatedButton.duration);
  }

  late final AnimationController controller;
  late final Animation<double> scaleAnimation = controller.drive(Tween<double>(begin: 0, end: 1));

  @override
  Future<bool> show() async {
    if (controller.value == 1 || controller.velocity > 0) return false;
    if (!isShowing) await super.show();

    await controller.forward();
    return true;
  }

  @override
  Future<bool> hide() async {
    if (!isShowing || controller.velocity < 0) return false;
    await controller.reverse();
    return super.hide();
  }

  Future<bool> hideInstancely() => super.hide();

  @nonVirtual
  @override
  Widget get tooltip => ScaleTransition(
    scale: scaleAnimation,
    alignment: position.followerAnchor,
    child: position.wrap(super.tooltip),
  );
}

abstract class GameTooltipPosition extends TooltipPosition {
  const factory GameTooltipPosition.centerLeft({GameTooltipBackgroundColor backgroundColor}) =
      _CenterLeft;
  const factory GameTooltipPosition.centerRight({GameTooltipBackgroundColor backgroundColor}) =
      _CenterRight;
  const factory GameTooltipPosition.centerTop({GameTooltipBackgroundColor backgroundColor}) =
      _CenterTop;
  const factory GameTooltipPosition.centerBottom({GameTooltipBackgroundColor backgroundColor}) =
      _CenterBottom;

  final GameTooltipBackgroundColor backgroundColor;

  const GameTooltipPosition({this.backgroundColor = GameTooltipBackgroundColor.notify});

  Widget wrap(Widget child);

  Path Function(Size size) get arrowPath;

  double get width;
  double get height;

  @nonVirtual
  Widget _wrapWithBackground(Widget child) => UnconstrainedBox(
    child: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: backgroundColor.value,
        borderRadius: const BorderRadius.all(Radius.circular(3)),
      ),
      child: child,
    ),
  );

  @nonVirtual
  Widget get arrow => ClipPath(
    clipper: _ArrowClip(arrowPath),
    child: Container(height: height, width: width, color: backgroundColor.value),
  );
}

class _CenterLeft extends GameTooltipPosition with PositionedOverlayCenterLeftMixin {
  const _CenterLeft({super.backgroundColor});

  @override
  Widget wrap(Widget child) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    mainAxisSize: MainAxisSize.min,
    children: [_wrapWithBackground(child), arrow],
  );

  @override
  double get height => 20;

  @override
  double get width => 10;

  @override
  Path Function(Size size) get arrowPath =>
      (size) => Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(0, size.height);
}

class _CenterRight extends GameTooltipPosition with PositionedOverlayCenterRightMixin {
  const _CenterRight({super.backgroundColor});

  @override
  Widget wrap(Widget child) => SizedBox(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [arrow, _wrapWithBackground(child)],
    ),
  );

  @override
  Path Function(Size size) get arrowPath =>
      (size) => Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height / 2);

  @override
  double get height => 20;

  @override
  double get width => 10;
}

class _CenterTop extends GameTooltipPosition with PositionedOverlayCenterTopMixin {
  const _CenterTop({super.backgroundColor});

  @override
  Path Function(Size size) get arrowPath =>
      (size) => Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height);

  @override
  double get height => 10;

  @override
  double get width => 20;

  @override
  Widget wrap(Widget rawChild) => Column(
    mainAxisAlignment: MainAxisAlignment.end,
    mainAxisSize: MainAxisSize.min,
    children: [_wrapWithBackground(rawChild), arrow],
  );
}

class _CenterBottom extends GameTooltipPosition with PositionedOverlayCenterBottomMixin {
  const _CenterBottom({super.backgroundColor});

  @override
  Path Function(Size size) get arrowPath =>
      (size) => Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width / 2, 0);

  @override
  double get height => 10;

  @override
  double get width => 20;

  @override
  Widget wrap(Widget rawChild) => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [arrow, _wrapWithBackground(rawChild)],
  );
}

class _ArrowClip extends CustomClipper<Path> {
  _ArrowClip(this._path);
  final Path Function(Size) _path;
  @override
  Path getClip(Size size) => _path(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class GameTooltipWrapper extends StatefulWidget {
  const GameTooltipWrapper({
    super.key,
    required this.child,
    this.position = const GameTooltipPosition.centerTop(),
    required this.tooltip,
  });

  final Widget child;

  final GameTooltipPosition position;
  final Widget tooltip;
  @override
  State<GameTooltipWrapper> createState() => _GameTooltipHoverWidgetState();
}

class _GameTooltipHoverWidgetState extends State<GameTooltipWrapper>
    with SingleTickerProviderStateMixin {
  late final GameTooltipController controller;

  late final GlobalKey key;
  late final AnimationController animController;
  late final FocusNode focusNode;
  bool isHover = false;
  @override
  void initState() {
    super.initState();
    key = GlobalKey();
    animController = AnimationController(vsync: this, duration: AnimatedButton.duration);
    controller = OverlayController.put(
      tag: hashCode.toString(),
      builder: () => GameTooltipController(
        tooltip: widget.tooltip,
        position: widget.position,
        controller: animController,
      ),
    );

    focusNode = FocusNode();
    focusNode.addListener(() {
      if (isHover) return;
      if (hasFocus) {
        controller.show();
      } else {
        controller.hide();
      }
    });
  }

  bool get hasFocus {
    for (var childFocusNode in focusNode.descendants) {
      if (childFocusNode.hasFocus) return true;
    }
    return false;
  }

  @override
  void dispose() {
    animController.dispose();
    focusNode.dispose();

    OverlayController.deleteCache(hashCode.toString());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      skipTraversal: true,
      canRequestFocus: false,
      child: MouseRegion(
        onEnter: (event) {
          isHover = true;
          if (hasFocus) return;
          controller.show();
        },
        onExit: (event) {
          isHover = false;
          if (hasFocus) return;
          controller.hide();
        },
        key: key,
        child: controller.attach(widget.child),
      ),
    );
  }
}
