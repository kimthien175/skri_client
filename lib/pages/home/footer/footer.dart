import 'package:cd_mobile/pages/home/footer/about.dart';
import 'package:cd_mobile/pages/home/footer/section.dart';
import 'package:cd_mobile/pages/home/footer/tutorial.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    var sections = [
      Section('about', 'section_about'.tr, const AboutContent()),
      Section('news', 'section_news'.tr, Container()),
      Section('how', 'section_how_to_play'.tr, const HowToPlayContent()),
    ];
    var isWeb = Get.find<HomeController>().isWebLayout.value;

    if (isWeb) {
      return Container(
          color: PanelStyles.color,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Column(children: [
            Wrap(
              children: sections,
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
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Nunito',
                    color: Color.fromRGBO(103, 122, 249, 1)))
          ]));
    } else {
      var mobilePanelWidth = PanelStyles.widthOnMobile;
      return Container(
          color: PanelStyles.color,
          child: Column(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
               SizedBox(height: mobilePanelWidth*0.05),
                Column(mainAxisSize: MainAxisSize.min, children: sections),
                Center(
                    child: SizedBox(
                        width: mobilePanelWidth*0.6,
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
                        fontSize: mobilePanelWidth* 0.03,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Nunito',
                        color: const Color.fromRGBO(103, 122, 249, 1))),
                        SizedBox(height: mobilePanelWidth*0.03)
              ]));
    }
  }
}

Widget _linkBuilder(String text, Function() onPressed) {
  var isWeb = Get.find<HomeController>().isWebLayout.value;
  return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
          onTap: onPressed,
          child: Text(text,
              style: TextStyle(
                  fontFamily: 'Nunito',
                  inherit: false,
                  fontWeight: FontWeight.w600,
                  fontSize: 16 ,
                  color: const Color.fromRGBO(180, 186, 255, 1),
                  decoration: TextDecoration.underline,
                  decorationColor: const Color.fromRGBO(180, 186, 255, 1),
                  decorationStyle: TextDecorationStyle.solid,
                  decorationThickness: isWeb ? 2 : 4))));
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
