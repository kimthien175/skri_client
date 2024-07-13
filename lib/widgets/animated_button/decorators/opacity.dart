import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../animated_button.dart';

class AnimatedButtonOpacityDecorator extends GetxController implements AnimatedButtonDecorator {
  AnimatedButtonOpacityDecorator({this.minOpacity = 0.5});

  final RxBool _visible = false.obs;
  final double minOpacity;

  @override
  void decorate(AnimatedButtonState state) {
    // modify onEnter and onExit behavior
    state.onEnterCallbacks.add((e) => _visible.value = true);
    state.onExitCallbacks.add((e) => _visible.value = false);

    // modify widget: wrap widget with AnimatedOpacity

    var widget = state.child;
    state.child = Obx(() => AnimatedOpacity(
        opacity: _visible.value ? 1 : minOpacity,
        duration: AnimatedButton.duration,
        child: widget));
  }

  @override
  void onClose() {
    throw Exception('This controller is supposed to be standalone, not via Get.put');
  }

  @override
  void Function() get clean => dispose;
}
