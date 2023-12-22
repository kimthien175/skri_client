import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';

extension HexColor on Color {
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class AboutContent extends StatelessWidget {
  const AboutContent({super.key});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      'section_about_content'.tr,
      customStylesBuilder: (element) {
        if (element.localName == 'b') {
          return {
            'color': PanelStyles.textColor.toHex(),
            'font-size': '16px',
            'font-weight': '700'
          };
        } else if (element.localName == 'span') {
          return {
            'color': PanelStyles.textColor.toHex(),
            'font-size': '16px',
            'font-weight': '500'
          };
        }
        return null;
      },
    );
  }
}