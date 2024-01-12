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

import 'controller.dart';

// TODO: WHEN USER ZOOM IN OR RESIZE TO SMALLER WIDTH, MAKE FOOTER SECTIONS JUMP DOWN LIKE TRUE MEANING OF WRAP
class Web extends StatelessWidget {
  Web({super.key});

  final controller = Get.put(WebController());

  @override
  Widget build(BuildContext context) {
    var mainContent = IntrinsicWidth(
        child: Column(key: controller.mainContentKey, mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 25),
      Logo(() => Get.offNamed('/')),
      const SizedBox(height: 10),
      const RandomAvatars(),
      const SizedBox(height: 40),
      Container(
          padding: PanelStyles.padding,
          decoration: PanelStyles.webDecoration,
          width: 400,
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
            key: controller.footerKey,
            mainAxisSize: MainAxisSize.min,
            children: const [Triangle(), Footer()]));

    // return Column(
    //   children: [
    //     Expanded(child: LayoutBuilder(builder: (cxt, constrants) {
    //       return SizedBox(
    //           height: constrants.maxHeight,
    //           child: SingleChildScrollView(
    //               child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: mainContent,
    //           )));
    //     })),
    //     ...footer
    //   ],
    // );
    var horizontalScrollController = ScrollController();
    return Obx(() {
      if (controller.firstRun.value) {
        var verticalScrollController = ScrollController();
        return MeasureSize(
            onChange: (size) {
              controller.processLayout();
              controller.firstRun.value = false;
            },
            child:
                // SingleChildScrollView(
                //     scrollDirection: Axis.horizontal,
                //     child: Container(
                //             constraints: BoxConstraints.loose(Get.find<HomeController>().originalSize),
                //             child: ListView(shrinkWrap: true, children: [mainContent, footer])))

                // vertical scroll bar show at the end of the right
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
      } else if (controller.isMinimumSize.value) {
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
        var verticalScrollController = ScrollController();
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

// NotificationListener<SizeChangedLayoutNotification> sizeListener(
//     {required Widget child, required bool Function(SizeChangedLayoutNotification) onSizeChanged}) {
//   return NotificationListener<SizeChangedLayoutNotification>(
//     onNotification: onSizeChanged,
//     child: SizeChangedLayoutNotifier(child: child),
//   );
// }
