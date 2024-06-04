import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'decorator.dart';

class AnimatedButtonBuilder {
  AnimatedButtonBuilder(
      {required this.child,
      this.onTap,
      List<AnimatedButtonDecorator>? decorators,
      // this.opacityDecorator,
      // this.scaleDecorator,
      // this.tooltipDecorator
      }) {
this.decorators = decorators ?? [];
    controller = Get.put(AnimatedButtonController(this));

    // decorating
    for (var decorator in this.decorators){
      decorator.decorate(this);
    }
    // opacityDecorator?.decorate(this);
    // scaleDecorator?.decorate(this);
    // tooltipDecorator?.decorate(this);
  }

  void cleanUp() {
    for (var callback in cleanUpCallbacks){
      callback();
    }
  }

  final List<void Function()> cleanUpCallbacks = [];

  final List<void Function()> onReverseEnd = [];

  late final AnimatedButtonController controller;

  void Function()? onTap;

  final List<void Function(PointerEnterEvent)> onEnter = [];
  final List<void Function(PointerExitEvent)> onExit = [];

  final GlobalKey buttonKey = GlobalKey();

  Widget child;

  late final List<AnimatedButtonDecorator> decorators;

  Widget build() {
    return GestureDetector(
        key: buttonKey,
        onTap: onTap,
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (e) {
              for (var callback in onEnter) {
                callback(e);
              }
              controller._controller.forward();
            },
            onExit: (e) {
              for (var callback in onExit) {
                callback(e);
              }
              controller._controller.reverse().then(
                (value) {
                  for (var callback in onReverseEnd) {
                    callback();
                  }
                },
              );
            },
            child: child));
  }
}

class AnimatedButtonController extends GetxController with GetSingleTickerProviderStateMixin {
  AnimatedButtonController(this.builder);

  final AnimatedButtonBuilder builder;

  //#region anim specs
  late final _controller =
      AnimationController(duration: duration, vsync: this, lowerBound: 0.9, upperBound: 1);
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
