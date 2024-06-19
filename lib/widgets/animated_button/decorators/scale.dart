import 'package:cd_mobile/widgets/animated_button/builder.dart';
import 'package:cd_mobile/widgets/animated_button/decorator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedButtonScaleDecorator extends AnimatedButtonDecorator
    with GetSingleTickerProviderStateMixin {
  AnimatedButtonScaleDecorator({double minSize = 0.8, double maxSize = 1}) {
    controller = AnimationController(
        duration: AnimatedButtonBuilder.duration,
        vsync: this,
        lowerBound: minSize,
        upperBound: maxSize);

    animation = CurvedAnimation(parent: controller, curve: Curves.linear);
  }
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void decorate(AnimatedButtonBuilder builder) {
    // wrap the widget with ScaleTransition
    var widget = builder.child;
    builder.child = ScaleTransition(scale: animation, child: widget);

    builder.onEnterCallbacks.add((_) {
      controller.forward();
    });

    builder.onExitCallbacks.add((_) {
      controller.reverse();
    });
  }

  @override
  void onClose() {
    print('scale decorator clear');
    controller.dispose();
    super.onClose();
  }
}
