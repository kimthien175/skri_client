library home_footer;

export 'about.dart';
export 'news.dart';
export 'section.dart';
export 'tutorial.dart';
export 'triangle.dart';

import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  //static const double webWidth = 1040;

  @override
  Widget build(BuildContext context) {
    if (context.width >= context.height) {
      return Container(
          width: double.infinity,
          color: PanelStyles.color,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 10),
                    Section('about', 'section_about'.tr, const AboutContent()),
                    Section('news', 'section_news'.tr, const NewsContent()),
                    Section('how', 'section_how_to_play'.tr, const HowToPlayContent()),
                    const SizedBox(width: 10)
                  ],
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ContactLink(),
                    SizedBox(width: 8),
                    _TermsLink(),
                    SizedBox(width: 8),
                    _CreditsLink()
                  ],
                ),
                Text('footer_caution'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12.8,
                        fontVariations: [FontVariation.weight(600)],
                        fontFamily: 'Nunito-var',
                        color: Color.fromRGBO(103, 122, 249, 1)))
              ]));
    } else {
      var mobilePanelWidth = PanelStyles.widthOnMobile;
      return Container(
          color: PanelStyles.color,
          child: Column(children: [
            SizedBox(height: mobilePanelWidth * 0.05),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Section('about', 'section_about'.tr, const AboutContent()),
              Section('news', 'section_news'.tr, const NewsContent()),
              Section('how', 'section_how_to_play'.tr, const HowToPlayContent()),
            ]),
            Center(
                child: SizedBox(
                    width: mobilePanelWidth * 0.6,
                    child: const FittedBox(
                        child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _ContactLink(),
                        SizedBox(width: 8),
                        _TermsLink(),
                        SizedBox(width: 8),
                        _CreditsLink()
                      ],
                    )))),
            Text('footer_caution'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: mobilePanelWidth * 0.03,
                    fontVariations: const [FontVariation.weight(600)],
                    fontFamily: 'Nunito-var',
                    color: const Color.fromRGBO(103, 122, 249, 1))),
            SizedBox(height: mobilePanelWidth * 0.03)
          ]));
    }
  }
}

Widget _linkBuilder(String text, Function() onPressed) {
  return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
          onTap: onPressed,
          child: Text(text,
              style: TextStyle(
                  fontFamily: 'Nunito-var',
                  inherit: false,
                  fontVariations: const [FontVariation.weight(600)],
                  fontSize: 16,
                  color: const Color.fromRGBO(180, 186, 255, 1),
                  decoration: TextDecoration.underline,
                  decorationColor: const Color.fromRGBO(180, 186, 255, 1),
                  decorationStyle: TextDecorationStyle.solid,
                  decorationThickness: Get.width >= Get.height ? 2 : 4))));
}

class _ContactLink extends StatelessWidget {
  const _ContactLink();
  @override
  Widget build(BuildContext context) {
    return _linkBuilder('link_contact'.tr, () async {
      final Uri params = Uri(
        scheme: 'mailto',
        path: 'contact@skribbl.io',
        //queryParameters: {'subject': 'Default Subject', 'body': 'Default body'}
      );

      if (await canLaunchUrl(params)) {
        await launchUrl(params);
      }
    });
  }
}

class _TermsLink extends StatelessWidget {
  const _TermsLink();

  @override
  Widget build(BuildContext context) {
    return _linkBuilder('link_terms'.tr, () {
      Get.toNamed('/terms');
    });
  }
}

class _CreditsLink extends StatelessWidget {
  const _CreditsLink();

  @override
  Widget build(BuildContext context) {
    return _linkBuilder('link_credits'.tr, () {
      Get.toNamed('/credits');
    });
  }
}
