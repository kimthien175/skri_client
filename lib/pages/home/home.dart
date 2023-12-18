import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/widgets/random_avatars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends SuperController {
  // var locale = Get.deviceLocale.toString().obs; // update when translations loading finish
  // String name = "";
  var isWebLayout = _isWebLayout.obs;

  static bool get _isWebLayout => Get.width >= Get.height;

  @override
  void didChangeMetrics() {
    isWebLayout.value = _isWebLayout;
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
            decoration: const BoxDecoration(
                image: DecorationImage(
                    scale: 1.2,
                    repeat: ImageRepeat.repeat,
                    image: AssetImage('assets/background.png'))),
            child: SafeArea(
                child: Center(
                    child: Obx(
                        () => controller.isWebLayout.value ? const _Web() : const _Mobile())))));
  }
}

class _Web extends StatelessWidget {
  const _Web();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            margin: const EdgeInsets.only(top: 25, bottom: 40),
            child: GifManager.inst.misc('logo').widgetWithShadow()),
        const SizedBox(height:10),
        RandomAvatars(),
      ],
    );
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    var logo = GifManager.inst.misc('logo').widgetWithShadow();

    var maxWidth = 0.65*Get.height;
    var width = 0.95*Get.width;
    var finalWidth = width > maxWidth ? maxWidth : width;
    var height = finalWidth*logo.model.ratio;
    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: Get.height * 0.06, bottom: Get.height * 0.04),
            width: finalWidth,
            height: height,
            child: FittedBox(child:logo)),
        const SizedBox(height: 10),
        RandomAvatars()
      ],
    );
  }
}
