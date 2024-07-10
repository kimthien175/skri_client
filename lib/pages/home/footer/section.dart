import 'package:skribbl_client/models/gif_manager.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Section extends StatelessWidget {
  const Section(this.icon, this.title, this.content, {super.key});
  final String icon;
  final String title;
  final Widget content;

  //static const double width = 340;
  @override
  Widget build(BuildContext context) {
    if (context.width >= context.height) {
      return Stack(children: [
        Container(
            width: 320,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(15),
            decoration: PanelStyles.webDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                    child: Text(title,
                        style: const TextStyle(
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
                child: FittedBox(child: GifManager.inst.misc(icon).builder.initShadowedOrigin())))
      ]);
    }
    return SizedBox(
        width: PanelStyles.widthOnMobile,
        child: FittedBox(
            child: Stack(children: [
          Container(
              width: 400,
              decoration: PanelStyles.mobileDecoration,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                      child: Text(title,
                          style: const TextStyle(
                              color: PanelStyles.textColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 22))),
                  const SizedBox(height: 8),
                  Container(margin: const EdgeInsets.all(10), child: content)
                ],
              )),
          Positioned(
              left: 16,
              top: 16,
              child: SizedBox(
                  width: 30,
                  height: 30,
                  child: FittedBox(child: GifManager.inst.misc(icon).builder.initShadowedOrigin())))
        ])));
  }
}
