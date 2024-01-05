import 'package:cd_mobile/pages/home/footer/news.dart';
import 'package:cd_mobile/pages/home/mobile/mobile.dart';
import 'package:cd_mobile/pages/home/web/controller.dart';
import 'package:cd_mobile/pages/home/web/web.dart';
import 'package:cd_mobile/pages/home/widgets/random_avatars.dart';
import 'package:cd_mobile/pages/page_controller/responsive_page_controller.dart';
import 'package:cd_mobile/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends ResponsivePageController {
  HomeController() : super() {
    Get.put(RandomAvatarsController());
    Get.put(NewsContentController());
  }

  //late Size originalSize;
  String _name = "";
  String get name {
    _name = _name.trim();
    // TODO: RANDOM NAME
    if (_name.isEmpty) return 'random name';
    return _name;
  }

  set name(String value) => _name = value;

  final contentKey = GlobalKey();

  var isLoading = false.obs;

  @override
  void didChangeMetrics() {
    // won't triggered on first run, only triggered when resize

    if (isWebLayout.value) {
      if (webLayoutStatus) {
        // constantly on web
        Get.find<WebController>().processLayout();
      } else {
        // from web to mobile
        isWebLayout.trigger(false);
      }
    } else {
      if (webLayoutStatus) {
        // from mobile to web
        isWebLayout.trigger(true);
      }
    }

    super.didChangeMetrics();
  }
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
          child: Obx(() {
            var content = SafeArea(child: controller.isWebLayout.value ? Web() : const Mobile());
            return controller.isLoading.value
                ? Stack(
                    children: [content, const LoadingOverlay()],
                  )
                : content;
          })),
    );
  }
}
