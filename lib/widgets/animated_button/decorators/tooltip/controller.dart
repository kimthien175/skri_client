import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../animated_button.dart';

class ScaleTooltipController extends GetxController with GetSingleTickerProviderStateMixin {
  late final animController = AnimationController(
      duration: AnimatedButton.duration, vsync: this, lowerBound: 0, upperBound: 1);
  late final Animation<double> animation =
      CurvedAnimation(parent: animController, curve: Curves.linear);

  @override
  void onClose() {
    throw Exception('Standalone controller');
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }
}
