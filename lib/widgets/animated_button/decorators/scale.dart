import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../animated_button.dart';

class AnimatedButtonScaleDecorator extends GetxController
    with GetSingleTickerProviderStateMixin
    implements AnimatedButtonDecorator {
  AnimatedButtonScaleDecorator({double minSize = defaultMinSize, double maxSize = defaultMaxSIze}) {
    controller = AnimationController(
        duration: AnimatedButton.duration, vsync: this, lowerBound: minSize, upperBound: maxSize);

    animation = CurvedAnimation(parent: controller, curve: Curves.linear);
  }
  late final AnimationController controller;
  late final Animation<double> animation;

  static const double defaultMinSize = 0.8;
  static const double defaultMaxSIze = 1.0;

  @override
  void decorate(AnimatedButtonState state) {
    // wrap the widget with ScaleTransition

    state.child = ScaleTransition(
      scale: animation,
      filterQuality: FilterQuality.high,
      child: state.child,
    );

    state.onEnterCallbacks.add((_) {
      controller.forward();
    });

    state.onExitCallbacks.add((_) {
      controller.reverse();
    });
  }

  @override
  void onClose() {
    throw Exception('This controller is supposed to be standalone, not via Get.put');
    // controller.dispose();
    // super.onClose();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void Function() get clean => dispose;
}
