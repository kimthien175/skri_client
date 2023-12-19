import 'dart:math';

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
        const SizedBox(height: 25),
        GifManager.inst.misc('logo').widgetWithShadow(),
        const SizedBox(height: 10),
        RandomAvatars(),
        const SizedBox(height: 40)
      ],
    );
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    var logo = GifManager.inst.misc('logo').widgetWithShadow();

    return Column(
      children: [
        SizedBox(height: Get.height * 0.06),
        SizedBox(
          width: min(0.65*Get.height, 0.95*Get.width),
            child: FittedBox(child:SizedBox(height: logo.model.height, child:logo))),
        const SizedBox(height: 10),
        RandomAvatars()
      ],
    );
  }
}
