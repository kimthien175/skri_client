import 'dart:math';

import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/pages/home/widgets/avatar_editor/avatar_editor.dart';
import 'package:cd_mobile/pages/home/footer/footer.dart';
import 'package:cd_mobile/pages/home/footer/triangle.dart';
import 'package:cd_mobile/pages/home/widgets/create_private_room_button.dart';
import 'package:cd_mobile/pages/home/widgets/lang_selector.dart';
import 'package:cd_mobile/pages/home/widgets/name_input.dart';
import 'package:cd_mobile/pages/home/widgets/play_button.dart';
import 'package:cd_mobile/pages/home/widgets/random_avatars.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:cd_mobile/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:measure_size/measure_size.dart';

class MobileController extends GetxController {
  final RxBool isFit = false.obs;
  void processLayout() {
    var homeController = Get.find<HomeController>();
    var mainHeight = homeController.mainContentKey.currentContext?.size?.height;
    var footerHeight = homeController.footerKey.currentContext?.size?.height;
    if (mainHeight != null && footerHeight != null) {
      isFit.value = mainHeight + footerHeight <= Get.height;
    } else {
      isFit.value = false;
    }
  }

  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

class Mobile extends GetView<MobileController> {
  const Mobile({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MobileController());

    // LESSION: use Get.width and Get.height instead of context.width and context.height, the widgets width will freeze, that's weird
    var w = context.width;
    var h = context.height;
    var homeController = Get.find<HomeController>();

    var mainContent = Column(
      key: homeController.mainContentKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: PanelStyles.widthOnMobile * 0.06),
        SizedBox(
            width: min(0.9 * w, 0.65 * h),
            child: FittedBox(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Logo(() => Get.offNamed('/')),
                const SizedBox(height: 10),
                const RandomAvatars()
              ],
            ))),
        SizedBox(height: 0.04 * w),
        SizedBox(
            width: PanelStyles.widthOnMobile,
            child: FittedBox(
                child: Container(
                    decoration: PanelStyles.mobileDecoration,
                    padding: PanelStyles.padding,
                    width: PanelStyles.width,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(children: [NameInput(), LangSelector()]),
                        AvatarEditor(),
                        PlayButton(),
                        SizedBox(height: 10),
                        CreatePrivateRoomButton(),
                      ],
                    )))),
      ],
    );

    var footer = Column(
      key: homeController.footerKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        Triangle(height: 0.02 * h),
        // ignore: prefer_const_constructors
        Footer(),
      ],
    );

    return Obx(() => MeasureSize(
        onChange: (_) => controller.processLayout(),
        child: controller.isFit.value
            ? SingleChildScrollView(
                child: Container(
                    width: w,
                    constraints: BoxConstraints(minHeight: h),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(width: w, child: mainContent),
                        Positioned(bottom: 0, child: SizedBox(width: w, child: footer))
                      ],
                    )))
            : Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                controller: controller.scrollController,
                child: SingleChildScrollView(
                    controller: controller.scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [mainContent, SizedBox(height: h * 0.05), footer],
                    )))));
  }
}
