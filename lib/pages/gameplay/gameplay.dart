library;

export 'layouts/web.dart';
export 'layouts/mobile.dart';
export 'widgets/widgets.dart';

import 'package:skribbl_client/models/game/state/draw/draw.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/pages/pages.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/page_background.dart';

import 'widgets/draw/manager.dart';

class GameplayBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(GameplayController());
  }
}

class GameplayController extends GetxController {
  GameplayController() : super() {
    Get.put(PlayersListController());
    Get.put(GameClockController());
    Get.put(GameChatController());

    Get.put(LikeAndDislikeController());
    DrawManager.init();

    Get.put(TopWidgetController());
    Get.put(HintController());
  }

  @override
  void onReady() {
    super.onReady();

    Game.inst.runState();

    // scroll to bottom
    Get.find<GameChatController>().scrollToBottom();
  }
}

class GameplayPage extends StatelessWidget {
  const GameplayPage({super.key});

  @override
  Widget build(BuildContext context) => Background(
      child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            Game.inst.confirmLeave();
          },
          child: const GameplayWeb()));
  //return context.width >= context.height ? const Web() : const Mobile();
}
