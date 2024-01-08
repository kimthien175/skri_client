import 'package:cd_mobile/pages/gameplay/mobile/mobile.dart';
import 'package:cd_mobile/pages/gameplay/web/web.dart';
import 'package:cd_mobile/pages/page_controller/responsive_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameplayController extends ResponsivePageController {
  GameplayController() : super();

  @override
  void didChangeMetrics() {
    isWebLayout.value = webLayoutStatus;
    super.didChangeMetrics();
  }
}

class GameplayPage extends StatelessWidget {
  GameplayPage({super.key});

  final GameplayController controller = Get.put(GameplayController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
                image: DecorationImage(
                    scale: 1.2,
                    repeat: ImageRepeat.repeat,
                    image: AssetImage('assets/background.png'))),
            child: SafeArea(
                child: Obx(() => controller.isWebLayout.value ? const Web() : const Mobile()))));
  }
}
