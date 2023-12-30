import 'dart:math';

import 'package:cd_mobile/models/avatar_editor/avatar_editor.dart';
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

class Mobile extends StatelessWidget {
  const Mobile({super.key});

  @override
  Widget build(BuildContext context) {
    //var logo = GifManager.inst.misc('logo').widgetWithShadow();

    var w = context.width;
    var h = context.height;

    var panelWidth = min(0.95 * w, 0.55 * h);
    return SingleChildScrollView(
        child: Column(
      children: [
        SizedBox(height: h * 0.06),
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
        Container(
            decoration: PanelStyles.mobileDecoration,
            width: panelWidth,
            child: FittedBox(
                child: Container(
                    padding: PanelStyles.padding,
                    width: 400,
                    child: Column(
                      //mainAxisSize: MainAxisSize.min,
                      children: [
                        const Row(children: [NameInput(), LangSelector()]),
                        AvatarEditor(),
                        const PlayButton(),
                        const CreatePrivateRoomButton(),
                      ],
                    )))),
        SizedBox(height: 0.05 * h),
        Triangle(height: 0.02 * h),
        Footer(),
      ],
    ));
  }
}
