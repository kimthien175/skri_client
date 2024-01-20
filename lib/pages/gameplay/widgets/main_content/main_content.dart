import 'package:cd_mobile/pages/gameplay/widgets/footer.dart';
import 'package:cd_mobile/pages/gameplay/widgets/game_canvas.dart';
import 'package:cd_mobile/pages/gameplay/widgets/game_settings.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content/overlay.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content/top_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainContent extends StatelessWidget {
  MainContent({super.key}) {
    Get.put(CanvasOverlayController());
    Get.put(TopWidgetController());
  }

  static Duration animationDuration = const Duration(milliseconds: 800);

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<MainContentController>();
    return Obx(() => controller.child.value);
  }
}

class MainContentController extends GetxController {
  MainContentController() {
    child = canvas.obs;
  }
  final Widget canvas = const GameCanvas();
  late Rx<Widget> child;
  showSettings() {
    child.value = Stack(
      children: [
        canvas,

        // animate overlay
        const CanvasOverlay(),
        // animated settings

        const TopWidget(child: GameSettings())
        // const GameSettings()
      ],
    );

    Get.find<CanvasOverlayController>().controller.forward().then(
      (value) {
        Get.find<TopWidgetController>().controller.forward();
      },
    );
  }

  showOverlay() {
    child.value = Stack(
      children: [
        canvas,

        // animate overlay
        const CanvasOverlay(),
        // animated settings
      ],
    );
    Get.find<CanvasOverlayController>().controller.forward();
  }

  showCanvas() async {
    // empty or show paint tools, that depends
    Get.find<GameFooterController>().empty();

    await Get.find<TopWidgetController>().controller.reverse();
    await Get.find<CanvasOverlayController>().controller.reverse();
    child.value = canvas;
  }
}
