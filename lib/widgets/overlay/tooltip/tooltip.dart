library game_tooltip;

export 'position.dart';
import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';

import '../../widgets.dart';
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

class GameTooltipWidget extends StatefulWidget {
  const GameTooltipWidget(
      {super.key,
      required this.child,
      this.scale = PositionedOverlayController.defaultScaler,
      this.position = const GameTooltipPosition.centerTop(),
      required this.tooltipContentBuilder});

  final Widget child;

  final double Function() scale;
  final GameTooltipPosition position;
  final Widget Function() tooltipContentBuilder;

  @override
  State<GameTooltipWidget> createState() => __TooltipWithWidgetState();
}

class __TooltipWithWidgetState extends State<GameTooltipWidget>
    with SingleTickerProviderStateMixin {
  late final GameTooltip
      controller; // no need to put in dispose(), when showing, OverlayController put itself in Getx smart management
  late final GlobalKey key;
  late final AnimationController animController;
  late final FocusNode focusNode;
  bool isHover = false;
  @override
  void initState() {
    super.initState();
    key = GlobalKey();
    animController = AnimationController(vsync: this, duration: AnimatedButton.duration);
    controller = GameTooltip(
        anchorKey: key,
        childBuilder: widget.tooltipContentBuilder,
        position: widget.position,
        scale: widget.scale,
        controller: animController);

    focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        if (focusNode.descendants.isNotEmpty) {
          focusNode.descendants.first.requestFocus();
        }
        if (isHover) return;
        controller.show();
      } else {
        if (isHover) return;
        controller.hide();
      }
    });
  }

  @override
  void dispose() {
    animController.dispose();
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        focusNode: focusNode,
        child: MouseRegion(
            onEnter: (event) {
              isHover = true;
              if (focusNode.hasFocus) return;
              controller.show();
            },
            onExit: (event) {
              isHover = false;
              if (focusNode.hasFocus) return;
              controller.hide();
            },
            key: key,
            child: widget.child));
  }
}
