import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../animated_button.dart';

class AnimatedButtonScaleDecorator extends GetxController
    with GetSingleTickerProviderStateMixin
    implements AnimatedButtonDecorator {
  AnimatedButtonScaleDecorator({double min = 1.0, double max = 1.1}) {
    animation = CurvedAnimation(parent: controller, curve: Curves.linear)
        .drive(Tween<double>(begin: min, end: max));
  }

  late final AnimationController controller =
      AnimationController(duration: AnimatedButton.duration, vsync: this);
  late final Animation<double> animation;

  @override
  void decorate(AnimatedButtonState state) {
    // wrap the widget with ScaleTransition

    state.child = ScaleTransition(
      scale: animation,
      filterQuality: FilterQuality.none,
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
