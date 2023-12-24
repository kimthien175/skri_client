import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.all(8),
                child: HtmlWidget("terms_content".tr, customStylesBuilder: (element) {
                  if (element.localName == 'body') {
                    return {
                      'display': 'block',
                      'margin': '8px',
                    };
                  } else if (element.localName == 'b') {
                    return {'font-weight': 'bold'};
                  } else if (element.localName == 'a') {
                    return {'color': 'blue', 'cursor': 'pointer', 'text-decoration': 'underline'};
                  }
                  return null;
                }, onTapUrl: (String? url) async {
                  final Uri params = Uri(
                    path: url,
                    //queryParameters: {'subject': 'Default Subject', 'body': 'Default body'}
                  );

                  return await launchUrl(params);
                }))));
  }
}
