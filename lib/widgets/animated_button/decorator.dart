import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'builder.dart';

class AnimatedButtonDecorator {
  void decorate(AnimatedButtonBuilder builder) {}
}

class AnimatedButtonOpacityDecorator extends AnimatedButtonDecorator {
  AnimatedButtonOpacityDecorator({this.minOpacity = 0.5});

  final RxBool _visible = false.obs;
  final double minOpacity;

  @override
  void decorate(AnimatedButtonBuilder builder) {
    // modify onEnter and onExit behavior
    builder.onEnter.add((e) => _visible.value = true);
    builder.onExit.add((e) => _visible.value = false);

    // modify widget: wrap widget with AnimatedOpacity

    var widget = builder.child;
    builder.child = Obx(() => AnimatedOpacity(
        opacity: _visible.value ? 1 : minOpacity,
        duration: AnimatedButtonController.duration,
        child: widget));

    builder.cleanUpCallbacks.add(()=>_visible.close());
  }
}

class AnimatedButtonScaleDecorator extends AnimatedButtonDecorator {
  AnimatedButtonScaleDecorator({this.minSize = 0.9, this.maxSize = 1});
  final double minSize;
  final double maxSize;
  @override
  void decorate(AnimatedButtonBuilder builder) {
    // wrap the widget with ScaleTransition
    var widget = builder.child;
    builder.child = ScaleTransition(scale: builder.controller.animation, child: widget);
  }
}
