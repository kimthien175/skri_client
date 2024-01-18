import 'package:cd_mobile/pages/gameplay/widgets/main_content/main_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopWidget extends StatelessWidget {
  const TopWidget({required this.child, super.key});

  final Widget child;
  @override
  Widget build(BuildContext context) {
    var controller = Get.find<TopWidgetController>();
    return ClipRect(
        child: SlideTransition(
            position: controller._animation,
            child: SizedBox(height: 600, width: 800, child:child)));
  }
}

class TopWidgetController extends GetxController with GetSingleTickerProviderStateMixin {
  TopWidgetController() {
    controller = AnimationController(
      duration: MainContent.animationDuration,
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
  }
  late final AnimationController controller;
  late final Animation<Offset> _animation;
}
