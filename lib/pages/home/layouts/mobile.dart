import 'dart:math';

import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeMobile extends StatelessWidget {
  const HomeMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        controller: scrollController,
        child: SingleChildScrollView(
            controller: scrollController,
            child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: context.height),
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: PanelStyles.widthOnMobile * 0.06),
                      SizedBox(
                          width: min(0.9 * context.width, 0.65 * context.height),
                          child: const FittedBox(
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [Logo(Logo.clearUrl), SizedBox(height: 10), RandomAvatars()],
                          ))),
                      SizedBox(height: 0.04 * context.width),
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
                                      SizedBox(height: 10),
                                      CreatePrivateRoomButton(),
                                    ],
                                  )))),
                      SizedBox(height: context.height * 0.05),
                    ],
                  ),
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [Triangle(height: 0.02 * context.height), const Footer()])
                ]))));
  }
}
