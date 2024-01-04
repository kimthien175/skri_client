import 'package:cd_mobile/utils/api.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

import 'dart:convert';

class NewsContent extends StatelessWidget {
  const NewsContent({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<NewsContentController>();
    return Obx(() {
      if (controller.content.isNotEmpty) {
        // ignore: invalid_use_of_protected_member
        var htmlString = utf8.decode(base64Decode(controller.content.value[Get.locale.toString()]!));

        return HtmlWidget(
          htmlString,
          customWidgetBuilder: (element) {
            if (element.classes.contains('head')) {
              List<String> texts = element.children
                  .map(
                    (e) => e.text,
                  )
                  .toList();
              return _Head(title: texts[0], date: texts[1]);
            }
            if (element.classes.contains('content')) {
              var scrollController = ScrollController();
              return Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: Scrollbar(
                      thumbVisibility: true,
                      trackVisibility: true,
                      controller: scrollController,
                      child: SingleChildScrollView(
                          controller: scrollController,
                          child: HtmlWidget(element.outerHtml,
                              textStyle: TextStyle(
                                  color: PanelStyles.textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                              customStylesBuilder: (element) => {'font-size': '0.93em'}))));
            }
            return null;
          },
        );
      }

      return Container();
    });
  }
}

class _Head extends StatelessWidget {
  const _Head({required this.title, required this.date});
  final String title;
  final String date;
  @override
  Widget build(BuildContext context) {
    var color = PanelStyles.textColor;

    //TODO: due to Footer's parent as IntrinsicWidth, children's LayoutBuilder and Row's crossAxisAlignment as Baseline are forbiden
    return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration:
            BoxDecoration(border: Border(bottom: BorderSide(color: PanelStyles.borderFocusColor))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18)),
            Text(date, style: TextStyle(color: color, fontWeight: FontWeight.w700))
          ],
        ));
  }
}

class NewsContentController extends GetxController {
  NewsContentController() {
    getLastestNews();
  }
  var content = <String, dynamic>{}.obs;

  void getLastestNews() async {
    final res = await API.inst.get('news');

    if (res.statusCode == 200) {
      content.value = jsonDecode(res.body);
    }
  }
}
