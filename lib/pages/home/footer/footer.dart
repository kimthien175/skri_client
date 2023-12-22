import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/pages/home/footer/about.dart';
import 'package:cd_mobile/pages/home/footer/section.dart';
import 'package:cd_mobile/pages/home/footer/tutorial.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        color: PanelStyles.color,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Section('about', 'section_about'.tr, const AboutContent()),
            Section('news', 'section_news'.tr, Container()),
            Section('how', 'section_how_to_play'.tr, const HowToPlayContent())
          ],
        ));
  }
}
