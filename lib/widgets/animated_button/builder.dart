import 'package:cd_mobile/widgets/animated_button/decorator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedButtonBuilder {
  AnimatedButtonBuilder({
    required this.child,
    this.onTap,
    required this.decorators,
  }) {
    controller = AnimatedButtonController(this);

    // decorating
    for (var decorator in decorators) {
      decorator.decorate(this);
    }
  }

  Widget child;
  void Function()? onTap;
  late final List<AnimatedButtonDecorator> decorators;

  late final AnimatedButtonController controller;

  final List<void Function(PointerEnterEvent)> onEnterCallbacks = [];
  final List<void Function(PointerExitEvent)> onExitCallbacks = [];

  final GlobalKey buttonKey = GlobalKey();

  Widget build() {
    return GestureDetector(
        key: buttonKey,
        onTap: onTap,
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (e) {
              for (var callback in onEnterCallbacks) {
                callback(e);
              }
              controller._controller.forward();
            },
            onExit: (e) {
              for (var callback in onExitCallbacks) {
                callback(e);
              }
              controller._controller.reverse();
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
    for (var decorator in builder.decorators){
      decorator.dis
    }
    _controller.dispose();
    super.dispose();
  }
}
