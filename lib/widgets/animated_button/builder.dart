import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'decorator.dart';
import 'decorators/tooltip.dart';

class AnimatedButtonBuilder {
  AnimatedButtonBuilder(
      {required this.child,
      this.onTap,
      this.opacityDecorator,
      this.scaleDecorator,
      this.tooltipDecorator}) {
    controller = Get.put(AnimatedButtonController(this));

    onEnter = (e) {
      controller._controller.forward();
      print('super onEnter');
    };

    onExit = (e) {
      controller._controller.reverse();
      print('super onExit');
    };

    // decorating
    opacityDecorator?.decorate(this);
    scaleDecorator?.decorate(this);
    tooltipDecorator?.decorate(this);
  }

  void cleanUp() {
    opacityDecorator?.cleanUp();
    tooltipDecorator?.removeOverlayEntry();
  }

  late final AnimatedButtonController controller;

  void Function()? onTap;

  late void Function(PointerEnterEvent) onEnter;
  late void Function(PointerExitEvent) onExit;

  final GlobalKey buttonKey = GlobalKey();

  Widget child;

  final AnimatedButtonOpacityDecorator? opacityDecorator;
  final AnimatedButtonScaleDecorator? scaleDecorator;
  final AnimatedButtonTooltipDecorator? tooltipDecorator;

  Widget build() {
    return GestureDetector(
        key: buttonKey,
        onTap: onTap,
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: onEnter,
            onExit: onExit,
            child: child));
  }
}

class AnimatedButtonController extends GetxController
    with GetSingleTickerProviderStateMixin {
  AnimatedButtonController(this.builder);

  final AnimatedButtonBuilder builder;

  //#region anim specs
  late final _controller = AnimationController(
      duration: duration, vsync: this, lowerBound: 0.9, upperBound: 1);
  static const Duration duration = Duration(milliseconds: 130);
  late final Animation<double> animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );
  //#endregion

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void onClose() {
    builder.cleanUp();
    super.onClose();
  }
}
