import 'dart:math';

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
import 'package:cd_mobile/widgets/single_child_2d_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Web extends StatelessWidget {
  const Web({super.key});

  static double minHeight = 1070.0;
  static const double minWidth = 1040.0;

  @override
  Widget build(BuildContext context) {
    final verticalScrollDetails = ScrollableDetails.vertical(controller: ScrollController());
    final horizontalScrollDetails = ScrollableDetails.horizontal(controller: ScrollController());
    return Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        controller: verticalScrollDetails.controller,
        child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            controller: horizontalScrollDetails.controller,
            child: SingleChild2DScrollView(
                verticalDetails: verticalScrollDetails,
                horizontalDetails: horizontalScrollDetails,
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
                          const Spacer(),
                          const Triangle(),
                          const Footer()
                        ]))))));
  }
}
