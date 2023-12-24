import 'package:cd_mobile/pages/home/footer/about.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:cd_mobile/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: url_laucher, something wrong, the link go along with the page link at the head of the result
class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  scale: 1.2,
                  repeat: ImageRepeat.repeat,
                  image: AssetImage('assets/background.png'),
                )),
                child: SafeArea(
                    child: SizedBox(
                        height: Get.height -
                            MediaQuery.of(context).padding.bottom -
                            MediaQuery.of(context)
                                .padding
                                .top, // based on ChatGPT the SafeArea's size is screen's size subtracting paddings
                        width: Get.width -
                            MediaQuery.of(context).padding.left -
                            MediaQuery.of(context).padding.right,
                        child: Column(children: [
                          const SizedBox(height: 25, width: double.infinity),
                          Logo(() => Get.offAllNamed('/')),
                          const SizedBox(height: 50),
                          Container(
                              width: 400,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: PanelStyles.color,
                                borderRadius: GlobalStyles.borderRadius,
                              ),
                              child:
                                  HtmlWidget("credits_content".tr, customStylesBuilder: (element) {
                                if (element.localName == 'h1') {
                                  return {'font-size': '2em', 'font-weight': 'bold'};
                                } else if (element.localName == 'a') {
                                  return {
                                    'color': '#b4baff',
                                    'cursor': 'pointer',
                                    'text-decoration': 'underline',
                                    'text-decoration-color':
                                        const Color.fromRGBO(180, 186, 255, 1).toHex()
                                  };
                                } else if (element.localName == 'b') {
                                  return {'font-weight': 'bold', 'color': '#fff'};
                                }
                                return null;
                              }, onTapUrl: (String? url) async {
                                final Uri params = Uri(
                                  path: url,
                                  //queryParameters: {'subject': 'Default Subject', 'body': 'Default body'}
                                );

                                return await launchUrl(params);
                              }))
                        ]))))));
  }
}
