import 'package:cd_mobile/models/game/game.dart';
import 'package:cd_mobile/pages/gameplay/mobile/mobile.dart';
import 'package:cd_mobile/pages/gameplay/web/web.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content_footer/main_content_footer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameplayBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameplayController>(() => GameplayController());
  }
}

class GameplayController extends GetxController {
  GameplayController() : super() {
    Get.put(MainContentAndFooterController());
  }
  static Function()? setUp;

  @override
  void onReady() {
    super.onReady();
    Game.inst.state.value.setup();
  }
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
              child: SafeArea(
                  child: context.width >= context.height ? const Web() : const Mobile()))));
}
