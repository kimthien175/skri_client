import 'dart:math';

import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeWeb extends StatelessWidget {
  const HomeWeb({super.key});

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
                        width: max(context.width, minWidth),
                        child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(
                            children: [
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
                                      Row(children: [
                                        NameInput(), //LangSelector()
                                      ]),
                                      AvatarEditor(),
                                      PlayButton(),
                                      SizedBox(height: 10),
                                      CreatePrivateRoomButton(),
                                    ],
                                  )),
                              const SizedBox(height: 20)
                            ],
                          ),
                          const Column(
                              mainAxisSize: MainAxisSize.min, children: [Triangle(), Footer()])
                        ]))))));
  }
}
