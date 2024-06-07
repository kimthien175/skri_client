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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:measure_size/measure_size.dart';

class WebController extends GetxController {
  final RxBool isHeightFit = false.obs;
  final RxBool isWidthFit = false.obs;
  void processLayout() {
    var homeController = Get.find<HomeController>();
    var mainSize = homeController.mainContentKey.currentContext?.size;
    var footerSize = homeController.footerKey.currentContext?.size;
    if (mainSize != null && footerSize != null) {
      isHeightFit.value = mainSize.height + footerSize.height <= Get.height;
      isWidthFit.value = mainSize.width + footerSize.width <= Get.width;
    } else {
      isHeightFit.value = false;
      isWidthFit.value = false;
    }
  }

  final horizontalScrollController = ScrollController();
  final verticalScrollController = ScrollController();

  @override
  void dispose() {
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    super.dispose();
  }
}

// TODO: WHEN USER ZOOM IN OR RESIZE TO SMALLER WIDTH, MAKE FOOTER SECTIONS JUMP DOWN LIKE TRUE MEANING OF WRAP
class Web extends GetView<WebController> {
  const Web({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(WebController());
    var homeController = Get.find<HomeController>();
    var mainContent =
        Column(key: homeController.mainContentKey, mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 25),
      Logo(() {
        // check if private code in url, then clean it
        Get.parameters = {};
      }),
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
    ]);

    var footer = Column(
      key: homeController.footerKey,
      mainAxisSize: MainAxisSize.min,
      children: const [Triangle(), Footer()],
    );

    return Obx(() => MeasureSize(
          onChange: (_) => controller.processLayout(),
          child: controller.isWidthFit.value
              ? (controller.isHeightFit.value
                  ?
                  // TODO: fit width and height
                  SingleChildScrollView(
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                              constraints:
                                  BoxConstraints(minHeight: Get.height, minWidth: Get.width),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [mainContent, Positioned(bottom: 0, child: footer)],
                              ))))
                  :
                  // TODO:  fit width but not height
                  Container())
              : (controller.isHeightFit.value
                  ?
                  // TODO:fit height but not width
                  Container()
                  :
                  // TODO:  fit no height nor width
                  SingleChildScrollView(
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                              constraints:
                                  BoxConstraints(minHeight: Get.height, minWidth: Get.width),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [mainContent, Positioned(bottom: 0, child: footer)],
                              ))))),
        ));
    // var controller = Get.find<HomeController>();
    // if (controller.isFit.value) {
    //   if (_widthController.isFit.value) {
    //     // fit height and width
    //     return MeasureSize(
    //         onChange: (_) {
    //           controller.processLayout();
    //           _widthController.processLayout();
    //         },
    //         child: SingleChildScrollView(
    //           scrollDirection: Axis.horizontal,
    //           child: SingleChildScrollView(
    //             child:
    //           )
    //         ));
    //   }
    //   // fit height, not width
    //   return MeasureSize(
    //       onChange: (_) {
    //         controller.processLayout();
    //         _widthController.processLayout();
    //       },
    //       child: Container());
    // }
    // if (_widthController.isFit.value) {
    //   // fit width, not height
    //   return MeasureSize(
    //       onChange: (_) {
    //         controller.processLayout();
    //         _widthController.processLayout();
    //       },
    //       child: Container());
    // }
    // // not fit width nor height
    // return MeasureSize(
    //     onChange: (_) {
    //       controller.processLayout();
    //       _widthController.processLayout();
    //     },
    //     child: Container());

    // TODO: vertical scrollbar has to stay in right of the screen, not the right of the widget
    // return Scrollbar(
    //     thumbVisibility: true,
    //     trackVisibility: true,
    //     scrollbarOrientation: ScrollbarOrientation.right,
    //     controller: verticalScrollController,
    //     child: Scrollbar(
    //         thumbVisibility: true,
    //         trackVisibility: true,
    //         controller: horizontalScrollController,
    //         child: SingleChildScrollView(
    //             controller: horizontalScrollController,
    //             scrollDirection: Axis.horizontal,
    //             child: SingleChildScrollView(
    //                 controller: verticalScrollController,
    //                 child: Column(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: [mainContent, footer],
    //                 )))));
    // } else if (homeController.isFit.value) {
    //   return Scrollbar(
    //       controller: horizontalScrollController,
    //       thumbVisibility: true,
    //       trackVisibility: true,
    //       child: SingleChildScrollView(
    //           controller: horizontalScrollController,
    //           scrollDirection: Axis.horizontal,
    //           child: Column(
    //             children: [mainContent, const Spacer(), footer],
    //           )));
    // } else {
    //   return Scrollbar(
    //       thumbVisibility: true,
    //       trackVisibility: true,
    //       controller: horizontalScrollController,
    //       child: SingleChildScrollView(
    //           controller: horizontalScrollController,
    //           scrollDirection: Axis.horizontal,
    //           child: SingleChildScrollView(
    //               controller: verticalScrollController,
    //               child: Column(
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [mainContent, footer],
    //               ))));
    // }
    // });
  }
}
