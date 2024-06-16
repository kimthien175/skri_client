import 'dart:math';

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
import 'package:cd_mobile/widgets/measure_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class _MobileController extends GetxController {
  final isFit = false.obs;
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

class Mobile extends GetView<_MobileController> {
  const Mobile({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(_MobileController());
    return Obx(() {
      Widget baseWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: PanelStyles.widthOnMobile * 0.06),
          SizedBox(
              width: min(0.9 * context.width, 0.65 * context.height),
              child: const FittedBox(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Logo(Logo.clearUrl), SizedBox(height: 10), RandomAvatars()],
              ))),
          SizedBox(height: 0.04 * context.width),
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
          controller.isFit.value ? const Spacer(): SizedBox(height: context.height * 0.05),
          Triangle(height: 0.02 * context.height),
          const Footer(),
        ],
      );
      if (controller.isFit.value) {
        baseWidget = SizedBox(height: context.height, child: baseWidget);
      }
      return Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          controller: controller.scrollController,
          child: SingleChildScrollView(
              controller: controller.scrollController,
              child: MeasureSize(
                  onChange: () {
                    controller.isFit.value =
                        controller.scrollController.position.maxScrollExtent == 0;
                  },
                  child: baseWidget)));
    });
  }
}
