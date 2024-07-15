library home;

export 'footer/footer.dart';
export 'layouts/web.dart';
export 'layouts/mobile.dart';
export 'widgets/widgets.dart';
export 'widgets/avatar_editor/avatar_editor.dart';

import 'package:skribbl_client/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/resources_ensurance.dart';

class HomeBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
  }
}

class HomeController extends GetxController {
  HomeController() : super() {
    if (ResourcesController.inst.isLoaded.value) {
      loadChildrenControllers();
    } else {
      ResourcesController.inst.onDone.add(loadChildrenControllers);
    }

    // check for room code
    var keys = Get.parameters.keys.toList();
    if (keys.isNotEmpty) {
      var rawRoomCode = keys[0];
      // change Play btn function
      PlayButton.roomCode = rawRoomCode.toLowerCase();
    }
  }

  void loadChildrenControllers() {
    Get.put(RandomAvatarsController());
    Get.put(AvatarEditorController());
    Get.put(NewsContentController());
    Get.put(HowToPlayContentController());
  }
}

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResourcesEnsurance(
        child: context.width >= context.height ? const HomeWeb() : const HomeMobile());
  }
}
