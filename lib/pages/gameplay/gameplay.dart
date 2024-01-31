import 'package:cd_mobile/models/game/game.dart';
import 'package:cd_mobile/pages/gameplay/mobile/mobile.dart';
import 'package:cd_mobile/pages/gameplay/web/web.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content_footer/main_content_footer.dart';
import 'package:cd_mobile/pages/page_controller/responsive_page_controller.dart';
import 'package:cd_mobile/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameplayBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameplayController>(() => GameplayController());
  }
}

class GameplayController extends ResponsivePageController {
  GameplayController() : super() {
    Get.put(MainContentAndFooterController());
  }
  static Function()? setUp;
  @override
  void didChangeMetrics() {
    isWebLayout.value = webLayoutStatus;
    super.didChangeMetrics();
  }

  @override
  void onReady() {
    super.onReady();
    Game.inst.state.value.setup();
  }

  var isLoading = false.obs;
}

class GameplayPage extends StatelessWidget {
  const GameplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<GameplayController>();
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          Game.inst.leave();
        },
        child: Scaffold(
            body: Container(
                constraints: const BoxConstraints.expand(),
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        scale: 1.2,
                        repeat: ImageRepeat.repeat,
                        image: AssetImage('assets/background.png'))),
                child: Obx(() {
                  var content =
                      SafeArea(child: controller.isWebLayout.value ? const Web() : const Mobile());
                  return controller.isLoading.value
                      ? Stack(
                          alignment: Alignment.center,
                          children: [content, const LoadingOverlay()],
                        )
                      : content;
                }))));
  }
}
