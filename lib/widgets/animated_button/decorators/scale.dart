import 'package:skribbl_client/widgets/animated_button/builder.dart';
import 'package:skribbl_client/widgets/animated_button/decorator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedButtonScaleDecorator extends GetxController
    with GetSingleTickerProviderStateMixin
    implements AnimatedButtonDecorator {
  AnimatedButtonScaleDecorator({double minSize = defaultMinSize, double maxSize = defaultMaxSIze}) {
    controller = AnimationController(
        duration: AnimatedButtonBuilder.duration,
        vsync: this,
        lowerBound: minSize,
        upperBound: maxSize);

    animation = CurvedAnimation(parent: controller, curve: Curves.linear);
  }
  late final AnimationController controller;
  late final Animation<double> animation;

  static const double defaultMinSize = 0.8;
  static const double defaultMaxSIze = 1.0;

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
