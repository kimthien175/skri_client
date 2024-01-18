import 'package:cd_mobile/pages/gameplay/widgets/game_canvas.dart';
import 'package:cd_mobile/pages/gameplay/widgets/game_settings.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content/overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key});

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
  final Widget settings = const GameSettings();
  late Rx<Widget> child;
  showSettings() {
    child.value = Stack(
      children: [
        canvas,

        // animated overlay
        const CanvasOverlay()
        // animated settings
        // const GameSettings()
      ],
    );
  }
}


