import 'package:skribbl_client/pages/gameplay/widgets/main_content_footer/main_content_footer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopWidget extends StatelessWidget {
  TopWidget({required Widget child, super.key}) {
    controller = Get.put(TopWidgetController(child: child));
  }
  late final TopWidgetController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
        child: SlideTransition(
            position: controller._animation,
            child: SizedBox(
                height: 600, width: 800, child: Center(child: Obx(() => controller.child.value)))));
  }
}

class TopWidgetController extends GetxController with GetSingleTickerProviderStateMixin {
  TopWidgetController({required Widget child}) {
    controller = AnimationController(
      duration: MainContent.animationDuration,
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

    this.child = child.obs;
  }
  late final AnimationController controller;
  late final Animation<Offset> _animation;

  late final Rx<Widget> child;
}
