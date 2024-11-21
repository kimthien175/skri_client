import 'package:skribbl_client/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';

class AboutContent extends StatelessWidget {
  const AboutContent({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
        style: const TextStyle(
            color: PanelStyles.textColor,
            fontSize: 16,
            fontVariations: [FontVariation.weight(500)]),
        child: HtmlWidget('section_about_content'.tr));
  }
}
