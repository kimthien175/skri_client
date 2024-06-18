import 'package:cd_mobile/widgets/animated_button/builder.dart';
import 'package:cd_mobile/widgets/animated_button/decorator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedButtonScaleDecorator extends  GetxController with GetSingleTickerProviderStateMixin implements AnimatedButtonDecorator {
  AnimatedButtonScaleDecorator({double minSize = 0.9, double maxSize = 1}){
    controller = AnimationController(duration: AnimatedButtonController.duration, vsync: this, lowerBound: minSize, upperBound: maxSize);
  }
  late final AnimationController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void decorate(AnimatedButtonBuilder builder) {
    // wrap the widget with ScaleTransition
    var widget = builder.child;
    builder.child = ScaleTransition(scale: builder.controller.animation, child: widget);

    // add dispose
    builder.disposeCallbacks.add(() {
      print('dispose scale controller');
      dispose();
    },);
  }
}