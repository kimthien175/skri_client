library game_play;

export 'layouts/web.dart';
export 'layouts/mobile.dart';
export 'widgets/widgets.dart';

import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/pages/pages.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/resources_ensurance.dart';

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
    Get.put(PlayersListController());
    Get.put(MainContentAndFooterController());
  }

  // @override
  // void onReady() {
  //   super.onReady();
  //   //  Game.inst.state.value.setup();
  // }
}

class GameplayPage extends StatelessWidget {
  const GameplayPage({super.key});

  @override
  Widget build(BuildContext context) => ResourcesEnsurance(
      child: PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            Game.inst.leave();
          },
          child: const GameplayWeb()));
  //return context.width >= context.height ? const Web() : const Mobile();
}
