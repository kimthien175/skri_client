import 'dart:math';

import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// TODO: test scrollcontroller
class HomeWeb extends StatefulWidget {
  const HomeWeb({super.key});

  static const double minWidth = 1040.0;

  @override
  State<HomeWeb> createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {
  late ScrollController verticalScrollController;
  late ScrollController horizontalScrollController;

  @override
  void initState() {
    super.initState();
    verticalScrollController = ScrollController();
    horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    verticalScrollController.dispose();
    horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        controller: verticalScrollController,
        child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            controller: horizontalScrollController,
            child: SingleChild2DScrollView(
                verticalDetails: ScrollableDetails.vertical(controller: verticalScrollController),
                horizontalDetails:
                    ScrollableDetails.horizontal(controller: horizontalScrollController),
                delegate: SingleChild2DDelegate(
                    child: SizedBox(
                        width: max(context.width, HomeWeb.minWidth),
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
                                      Row(children: [NameInput(), LangSelector()]),
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
