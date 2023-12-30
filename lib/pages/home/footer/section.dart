import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Section extends StatelessWidget {
  const Section(this.icon, this.title, this.content, {super.key});
  final String icon;
  final String title;
  final Widget content;
  @override
  Widget build(BuildContext context) {
    var isWeb = Get.find<HomeController>().isWebLayout.value;
    var widget = Stack(children: [
      Container(
          width: 320,
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(15),
          decoration: PanelStyles.webDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                  child: Text(title,
                      style: TextStyle(
                          color: PanelStyles.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 24))),
              const SizedBox(height: 20),
              content
            ],
          )),
      Positioned(
          left: 28,
          top: 28,
          child: SizedBox(
              width: 32,
              height: 32,
              child: FittedBox(child: GifManager.inst.misc(icon).widgetWithShadow())))
    ]);
    if (isWeb) {
      return widget;
    }
    return Container(
        width: PanelStyles.widthOnMobile,
        decoration: PanelStyles.mobileDecoration,
        child: FittedBox(child: widget));
  }
}
