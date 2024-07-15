import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../animated_button.dart';

class AnimatedButtonScaleDecorator extends GetxController
    with GetSingleTickerProviderStateMixin
    implements AnimatedButtonDecorator {
  AnimatedButtonScaleDecorator.min({double scale = 0.8}) {
    controller =
        AnimationController(duration: AnimatedButton.duration, vsync: this, lowerBound: scale);

    animation = CurvedAnimation(parent: controller, curve: Curves.linear);

    _decorateWidget = (Widget widget) => ScaleTransition(
          scale: animation,
          // filterQuality: FilterQuality.high,
          child: widget,
        );
  }

  AnimatedButtonScaleDecorator.max({double scale = 1.1}) {
    controller =
        AnimationController(duration: AnimatedButton.duration, vsync: this, lowerBound: 1 / scale);
    animation = CurvedAnimation(parent: controller, curve: Curves.linear);

    _decorateWidget = (Widget widget) => Transform.scale(
        scale: scale,
        child: ScaleTransition(
          scale: animation,
          filterQuality: FilterQuality.none,
          child: widget,
        ));
  }

  late final Widget Function(Widget widget) _decorateWidget;

  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void decorate(AnimatedButtonState state) {
    // wrap the widget with ScaleTransition

    state.child = _decorateWidget(state.child);

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
