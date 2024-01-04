import 'package:cd_mobile/pages/home/footer/news.dart';
import 'package:cd_mobile/pages/home/mobile/mobile.dart';
import 'package:cd_mobile/pages/home/web/controller.dart';
import 'package:cd_mobile/pages/home/web/web.dart';
import 'package:cd_mobile/pages/home/widgets/random_avatars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends SuperController {
  HomeController() {
    isWebLayout = _isWebLayout.obs;
    Get.put(RandomAvatarsController());
    Get.put(NewsContentController());
    //originalSize = Get.size;
  }

  //late Size originalSize;
  String name = "";
  late RxBool isWebLayout;

  static bool get _isWebLayout => Get.width >= Get.height;

  final contentKey = GlobalKey();

  @override
  void didChangeMetrics() {
    // won't triggered on first run, only triggered when resize

    if (isWebLayout.value) {
      if (_isWebLayout) {
        // constantly on web
        Get.find<WebController>().processLayout();
      } else {
        // from web to mobile
        isWebLayout.trigger(false);
      }
    } else {
      if (_isWebLayout) {
        // from mobile to web
        isWebLayout.trigger(true);
      }
    }

    super.didChangeMetrics();
  }

  //#region Override to sastisfy SuperController, no need to get attention
  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {}
  //#endregion
}

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomePage({super.key});

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
            child:
                SafeArea(child: Obx(() => controller.isWebLayout.value ? Web() : const Mobile()))));
  }
}
