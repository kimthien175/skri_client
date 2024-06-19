import 'package:cd_mobile/widgets/animated_button/builder.dart';
import 'package:cd_mobile/widgets/animated_button/decorator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedButtonOpacityDecorator extends AnimatedButtonDecorator {
  AnimatedButtonOpacityDecorator({this.minOpacity = 0.5});

  final RxBool _visible = false.obs;
  final double minOpacity;

  @override
  void decorate(AnimatedButtonBuilder builder) {
    // modify onEnter and onExit behavior
    builder.onEnterCallbacks.add((e) => _visible.value = true);
    builder.onExitCallbacks.add((e) => _visible.value = false);

    // modify widget: wrap widget with AnimatedOpacity

    var widget = builder.child;
    builder.child = Obx(() => AnimatedOpacity(
        opacity: _visible.value ? 1 : minOpacity,
        duration: AnimatedButtonBuilder.duration,
        child: widget));
  }
}