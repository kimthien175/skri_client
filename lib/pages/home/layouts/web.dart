import 'dart:math';

import 'package:cd_mobile/pages/home/home.dart';
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
import 'package:cd_mobile/widgets/measure_size.dart';
import 'package:cd_mobile/widgets/single_child_2d_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebController extends GetxController {
  static bool get checkWidth => Get.width >= Web.minWidth;
  static bool get checkHeight => Get.height >= Web.minHeight;

  final RxBool isHeightFit = checkHeight.obs;
  final RxBool isWidthFit = checkWidth.obs;

  void processLayout() {
    var homeController = Get.find<HomeController>();
    var mainSize = homeController.mainContentKey.currentContext?.size;
    var footerSize = homeController.footerKey.currentContext?.size;
    if (mainSize != null && footerSize != null) {
      isHeightFit.value = mainSize.height + footerSize.height <= Get.height;
      isWidthFit.value = checkWidth;
    } else {
      isHeightFit.value = false;
      isWidthFit.value = false;
    }
  }

  ScrollController? get horizontalScrollController => horizontalScrollDetails.controller;
  ScrollController? get verticalScrollController => verticalScrollDetails.controller;

  final verticalScrollDetails = const ScrollableDetails.vertical();
  final horizontalScrollDetails = const ScrollableDetails.horizontal();

  @override
  void dispose() {
    verticalScrollController?.dispose();
    horizontalScrollController?.dispose();
    super.dispose();
  }
}

class Web extends GetView<WebController> {
  const Web({super.key});

  static double minHeight = 1052.0;
  static const double minWidth = 1040.0;

  @override
  Widget build(BuildContext context) {
    Get.put(WebController());
    return
        // Scrollbar(
        //                 thumbVisibility: true,
        //                 trackVisibility: true,
        //                 controller: controller.verticalScrollController,
        //                 child: Scrollbar(
        //                     thumbVisibility: true,
        //                     trackVisibility: true,
        //                     controller: controller.horizontalScrollController,
        //                     child:
        SingleChild2DScrollView(
      delegate: SingleChild2DDelegate(
          child: SizedBox(
              height: max(context.height, minHeight),
              width: max(context.width, minWidth),
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const SizedBox(height: 25),
                const Logo(Logo.clearUrl),
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
                const SizedBox(height: 20),
                const Spacer(),
                const Triangle(),
                const Footer()
              ]))),
      verticalDetails: controller.verticalScrollDetails,
      horizontalDetails: controller.horizontalScrollDetails,
    );
  }
}

class MyScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return Scrollbar(
        thumbVisibility: details.direction == Axis.vertical
            ? details.controller!.position.maxScrollExtent > 0
            : details.controller!.position.maxScrollExtent > 0,
        controller: details.controller,
        child: child);
  }
}
