import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/pages/home/layouts/base.dart';
import 'package:cd_mobile/pages/home/widgets/avatar_editor/avatar_editor.dart';
import 'package:cd_mobile/pages/home/footer/footer.dart';
import 'package:cd_mobile/pages/home/footer/triangle.dart';
import 'package:cd_mobile/pages/home/widgets/create_private_room_button.dart';
import 'package:cd_mobile/pages/home/widgets/lang_selector.dart';
import 'package:cd_mobile/pages/home/widgets/name_input.dart';
import 'package:cd_mobile/pages/home/widgets/play_button.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:cd_mobile/widgets/logo.dart';
import 'package:cd_mobile/pages/home/widgets/random_avatars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:measure_size/measure_size.dart';

// TODO: WHEN USER ZOOM IN OR RESIZE TO SMALLER WIDTH, MAKE FOOTER SECTIONS JUMP DOWN LIKE TRUE MEANING OF WRAP
class Web extends HomeLayout {
  Web({super.key});

  @override
  Widget build(BuildContext context) {
    var homeController = Get.find<HomeController>();
    var mainContent = IntrinsicWidth(
        child: Column(
            key: homeController.mainContentKey,
            mainAxisSize: MainAxisSize.min,
            children: [
          const SizedBox(height: 25),
          Logo(() => Get.offNamed('/')),
          const SizedBox(height: 10),
          const RandomAvatars(),
          const SizedBox(height: 40),
          Container(
              padding: PanelStyles.padding,
              decoration: PanelStyles.webDecoration,
              width: PanelStyles.width,
              child: const Column(
                children: [
                  Row(children: [NameInput(), LangSelector()]),
                  AvatarEditor(),
                  PlayButton(),
                  SizedBox(height: 10),
                  CreatePrivateRoomButton(),
                ],
              )),
          const SizedBox(height: 10)
        ]));
    var footer = IntrinsicWidth(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            key: homeController.footerKey,
            mainAxisSize: MainAxisSize.min,
            children: const [Triangle(), Footer()]));

    var horizontalScrollController = ScrollController();
    var verticalScrollController = ScrollController();

    return Obx(() {
      if (layoutController.firstRun.value) {
        return MeasureSize(
            onChange: (size) {
              homeController.processLayout();
              layoutController.firstRun.value = false;
            },
            child:
                // TODO: vertical scrollbar has to stay in right of the screen, not the right of the widget
                Scrollbar(
                    thumbVisibility: true,
                    trackVisibility: true,
                    scrollbarOrientation: ScrollbarOrientation.right,
                    controller: verticalScrollController,
                    child: Scrollbar(
                        thumbVisibility: true,
                        trackVisibility: true,
                        controller: horizontalScrollController,
                        child: SingleChildScrollView(
                            controller: horizontalScrollController,
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                                controller: verticalScrollController,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [mainContent, footer],
                                ))))));
      } else if (homeController.isMinimumSize.value) {
        return Scrollbar(
            controller: horizontalScrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
                controller: horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [mainContent, const Spacer(), footer],
                )));
      } else {
        return Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            controller: horizontalScrollController,
            child: SingleChildScrollView(
                controller: horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                    controller: verticalScrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [mainContent, footer],
                    ))));
      }
    });
  }
}
