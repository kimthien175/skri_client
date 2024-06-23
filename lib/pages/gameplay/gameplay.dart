import 'package:cd_mobile/models/game/game.dart';
import 'package:cd_mobile/pages/gameplay/layouts/web.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content_footer/main_content_footer.dart';
import 'package:cd_mobile/utils/start_up.dart';
import 'package:cd_mobile/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameplayBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(GameplayController());
  }
}

class GameplayController extends GetxController {
  GameplayController() : super() {
    if (ResourcesController.inst.isLoaded.value) {
      loadChildrenControllers();
    } else {
      ResourcesController.inst.onDone.add(loadChildrenControllers);
    }
  }

  void loadChildrenControllers() {
    Get.put(MainContentAndFooterController());
  }

  static Function()? setUp;

  // @override
  // void onReady() {
  //   super.onReady();
  //   //  Game.inst.state.value.setup();
  // }
}

class GameplayPage extends StatelessWidget {
  const GameplayPage({super.key});

  @override
  Widget build(BuildContext context) => PopScope(
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
              child: SafeArea(child: Obx(
                () {
                  if (!ResourcesController.inst.isLoaded.value) return const LoadingOverlay();
                  return const Web();
                  //return context.width >= context.height ? const Web() : const Mobile();
                },
              )))));
}
