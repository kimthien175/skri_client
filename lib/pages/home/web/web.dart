import 'package:cd_mobile/models/avatar_editor/avatar_editor.dart';
import 'package:cd_mobile/pages/home/footer/footer.dart';
import 'package:cd_mobile/pages/home/footer/triangle.dart';
import 'package:cd_mobile/pages/home/widgets/create_private_room_button.dart';
import 'package:cd_mobile/pages/home/widgets/lang_selector.dart';
import 'package:cd_mobile/pages/home/widgets/name_input.dart';
import 'package:cd_mobile/pages/home/widgets/play_button.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:cd_mobile/widgets/logo.dart';
import 'package:cd_mobile/widgets/random_avatars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:measure_size/measure_size.dart';

import 'controller.dart';

class Web extends StatelessWidget {
  Web({super.key});

  final controller = Get.put(WebController());

  @override
  Widget build(BuildContext context) {
    var mainContent = Center(
        child: Column(key: controller.mainContentKey, mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 25),
      Logo(() => Get.offNamed('/')),
      const SizedBox(height: 10),
      RandomAvatars(),
      const SizedBox(height: 40),
      Container(
          padding: PanelStyles.padding,
          decoration: PanelStyles.decoration,
          width: 400,
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            children: [
              const Row(children: [NameInput(), LangSelector()]),
              AvatarEditor(),
              const PlayButton(),
              const CreatePrivateRoomButton(),
            ],
          )),
    ]));
    var footer = Column(
        key: controller.footerKey,
        mainAxisSize: MainAxisSize.min,
        children: const [Triangle(), Footer()]);

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

    return Obx(() {
      print(controller.isMinimumSize.value);
      // if (controller.firstRun.value) {
      return MeasureSize(
          onChange: (size) {
            controller.processLayout();
            controller.firstRun.value = false;
          },
          child: Scrollbar(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    primary: true,
                      child: Column(
                          mainAxisSize: MainAxisSize.min, children: [mainContent, footer])))));
      // } else {
      //   if (controller.isMinimumSize.value) {
      //     return Stack(
      //       children: [
      //         SingleChildScrollView(
      //           child: mainContent,
      //         ),
      //         Container(
      //           constraints: const BoxConstraints.expand(),
      //           alignment: Alignment.bottomCenter,
      //           child: footer,
      //         )
      //       ],
      //     );
      //   } else {
      //     return SingleChildScrollView(
      //       child: Column(mainAxisSize: MainAxisSize.min, children: [mainContent, footer]),
      //     );
      //   }
      // }
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
