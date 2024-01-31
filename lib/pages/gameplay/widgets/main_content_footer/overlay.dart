import 'package:cd_mobile/pages/gameplay/widgets/main_content_footer/main_content_footer.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CanvasOverlay extends StatelessWidget {
  const CanvasOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<CanvasOverlayController>();
    return FadeTransition(
        opacity: controller._animation,
        child: Container(
          height: 600,
          width: 800,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(3, 8, 29, 0.8),
            borderRadius: GlobalStyles.borderRadius,
          ),
        ));
  }
}

class CanvasOverlayController extends GetxController with GetSingleTickerProviderStateMixin {
  CanvasOverlayController() {
    controller = AnimationController(
      duration: MainContentAndFooter.animationDuration,
      vsync: this,
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(controller);
  }
  late final AnimationController controller;
  late final Animation<double> _animation;
}
