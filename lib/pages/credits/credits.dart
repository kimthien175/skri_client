import 'package:skribbl_client/pages/home/footer/about.dart';
import 'package:skribbl_client/utils/navigator_observer.dart';
import 'package:skribbl_client/utils/start_up.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/loading.dart';
import 'package:skribbl_client/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  Future<bool> _launchUrl(String? url) {
    return launchUrl(Uri.parse(url!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
                image: DecorationImage(
              scale: 1.2,
              repeat: ImageRepeat.repeat,
              image: AssetImage('assets/background.png'),
            )),
            child: SafeArea(child: Obx(() {
              if (!ResourcesController.inst.isLoaded.value) {
                return LoadingOverlay.inst;
              }

              return Column(children: [
                const SizedBox(height: 25),
                Logo(() => Get.safelyToNamed('/')),
                const SizedBox(height: 50),
                Container(
                    width: 400,
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: PanelStyles.color,
                      borderRadius: GlobalStyles.borderRadius,
                    ),
                    child: HtmlWidget("credits_content".tr, customStylesBuilder: (element) {
                      if (element.localName == 'h1') {
                        return {'font-size': '2em', 'font-weight': 'bold'};
                      } else if (element.localName == 'a') {
                        return {
                          'color': '#b4baff',
                          'cursor': 'pointer',
                          'text-decoration': 'underline',
                          'text-decoration-color': const Color.fromRGBO(180, 186, 255, 1).toHex()
                        };
                      } else if (element.localName == 'b') {
                        return {'font-weight': 'bold', 'color': '#fff'};
                      }
                      return null;
                    }, onTapUrl: _launchUrl))
              ]);
            }))));
  }
}
