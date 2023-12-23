import 'package:cd_mobile/pages/home/footer/about.dart';
import 'package:cd_mobile/pages/home/footer/section.dart';
import 'package:cd_mobile/pages/home/footer/tutorial.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        color: PanelStyles.color,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Section('about', 'section_about'.tr, const AboutContent()),
              Section('news', 'section_news'.tr, Container()),
              Section('how', 'section_how_to_play'.tr, const HowToPlayContent())
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
              style: const TextStyle(
                  fontSize: 12.8,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito',
                  color: Color.fromRGBO(103, 122, 249, 1)))
        ]));
  }
}

Widget _linkBuilder(String text, Function() onPressed) {
  return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
          onTap: onPressed,
          child: Text(text,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  inherit: false,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color.fromRGBO(180, 186, 255, 1),
                  decoration: TextDecoration.underline,
                  decorationColor: Color.fromRGBO(180, 186, 255, 1),
                  decorationStyle: TextDecorationStyle.solid,
                  decorationThickness: 2))));
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
