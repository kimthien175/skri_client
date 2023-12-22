import 'package:cd_mobile/pages/home/footer/section.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
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
            Section('about', 'section_about'.tr, AboutContent('section_about_content'.tr)),
            Section('news', 'section_news'.tr, Container()),
            Section('how', 'section_how_to_play'.tr, Container())
          ],
        ));
  }
}



extension HexColor on Color{
    String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class AboutContent extends StatelessWidget {
  const AboutContent(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      text,
      customStylesBuilder: (element) {
        if (element.localName == 'b') {
          return {'color': PanelStyles.textColor.toHex(),'font-size':'16px', 'font-weight': '700'};
        } else if (element.localName == 'span') {
          return { 'color':PanelStyles.textColor.toHex(), 'font-size':'16px', 'font-weight': '500' };
        }
        return null;
      },
    );
  }
}
