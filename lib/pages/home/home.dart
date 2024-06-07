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
      Get.put(RandomAvatarsController());
      Get.put(NewsContentController());
      Get.put(AvatarEditorController());
    } else {
      ResourcesController.inst.onDone.add(() {
        Get.put(RandomAvatarsController());
        Get.put(NewsContentController());
        Get.put(AvatarEditorController());
      });
    }

    // check for room code
    var keys = Get.parameters.keys.toList();
    if (keys.isNotEmpty) {
      var rawRoomCode = keys[0];
      // change Play btn function
      PlayButton.roomCode = rawRoomCode.toLowerCase();
    }
  }

  var isLoading = false.obs;

  @override
  void didChangeMetrics() {
    // won't triggered on first run, only triggered when resize
    processLayout();
    if (isWebLayout.value != webLayoutStatus) {
      isWebLayout.toggle();
    }

    // if (isWebLayout.value) {
    //   if (webLayoutStatus) {
    //     // constantly on web
    //     Get.find<WebController>().processLayout();
    //   } else {
    //     // from web to mobile
    //     isWebLayout.trigger(false);
    //   }
    // } else {
    //   if (webLayoutStatus) {
    //     // from mobile to web
    //     isWebLayout.trigger(true);
    //   }
    // }

    super.didChangeMetrics();
  }

  var mainContentKey = GlobalKey();
  var footerKey = GlobalKey();

  var isFit = false.obs;

  void processLayout() {
    var mainHeight = mainContentKey.currentContext?.size?.height;
    var footerHeight = footerKey.currentContext?.size?.height;
    if (mainHeight != null && footerHeight != null) {
      var _isFit = mainHeight + footerHeight <= Get.height;
      if (isFit.value != _isFit) {
        isFit.trigger(_isFit);
      }
    } else {
      if (isFit.value) {
        isFit.trigger(false);
      }
    }
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final HomeController controller = Get.put(HomeController());

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
          child: Obx(() {
            if (!ResourcesController.inst.isLoaded.value) return const LoadingOverlay();

            var content = SafeArea(child: controller.isWebLayout.value ? Web() : Mobile());
            return controller.isLoading.value
                ? Stack(
                    children: [content, const LoadingOverlay()],
                  )
                : content;
          })),
    );
  }
}
