import 'package:cd_mobile/pages/home/footer/news.dart';
import 'package:cd_mobile/pages/home/layouts/mobile.dart';
import 'package:cd_mobile/pages/home/layouts/web.dart';
import 'package:cd_mobile/pages/home/widgets/avatar_editor/controller.dart';
import 'package:cd_mobile/pages/home/widgets/play_button.dart';
import 'package:cd_mobile/pages/home/widgets/random_avatars.dart';
import 'package:cd_mobile/pages/page_controller/responsive_page_controller.dart';
import 'package:cd_mobile/utils/start_up.dart';
import 'package:cd_mobile/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends ResponsivePageController {
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
    Get.put(NewsContentController());
    Get.put(AvatarEditorController());
  }

  @override
  void didChangeMetrics() {
    // won't triggered on first run, only triggered when resize
    // if (isWebLayout.value) {
    //   Get.find<WebController>().processLayout();
    // } else {
    //   Get.find<MobileController>().processLayout();
    // }
    if (isWebLayout.value != webLayoutStatus) {
      isWebLayout.toggle();
    }

    super.didChangeMetrics();
  }

  var mainContentKey = GlobalKey();
  var footerKey = GlobalKey();
}

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return Scaffold(
      body: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
              image: DecorationImage(
                  scale: 1.2,
                  repeat: ImageRepeat.repeat,
                  image: AssetImage('assets/background.png'))),
          child: SafeArea(child: Obx(() {
            if (!ResourcesController.inst.isLoaded.value) return const LoadingOverlay();

            return controller.isWebLayout.value ? const Web() : const Mobile();
          }))),
    );
  }
}
