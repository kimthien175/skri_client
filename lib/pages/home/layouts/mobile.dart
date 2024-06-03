import 'dart:math';

import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/pages/home/layouts/base.dart';
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

class Mobile extends HomeLayout {
  Mobile({super.key});

  @override
  Widget build(BuildContext context) {
    var w = context.width;
    var h = context.height;
    var homeController = Get.find<HomeController>();
    var verticalScrollController = ScrollController();

    return Obx(() {
      var mainContent = Column(
        key: homeController.mainContentKey,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: PanelStyles.widthOnMobile * 0.06),
          SizedBox(
              width: min(0.95 * w, 0.65 * h),
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

      if (layoutController.firstRun.value) {
        return MeasureSize(
            onChange: (size) {
              homeController.processLayout();
              layoutController.firstRun.value = false;
            },
            child: Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                controller: verticalScrollController,
                child: SingleChildScrollView(
                    controller: verticalScrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [mainContent, footer],
                    ))));
      } else if (homeController.isMinimumSize.value) {
        return Column(
          children: [mainContent, const Spacer(), footer],
        );
      }
      return Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          controller: verticalScrollController,
          child: SingleChildScrollView(
              controller: verticalScrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [mainContent, SizedBox(height: 0.05 * h), footer],
              )));
    });
  }
}
