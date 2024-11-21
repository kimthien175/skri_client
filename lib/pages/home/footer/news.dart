import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

import 'dart:convert';

import 'package:skribbl_client/utils/utils.dart';

// TODO: test scrollcontroller
class NewsContent extends StatelessWidget {
  const NewsContent({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<NewsContentController>();
    return Obx(() {
      if (controller.content.isNotEmpty) {
        var htmlString = utf8.decode(base64Decode(controller.content[Get.locale.toString()]!));

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
              var scrollController = controller.scrollController;
              return Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: RawScrollbar(
                      trackRadius: const Radius.circular(7),
                      radius: const Radius.circular(7),
                      trackColor: const Color.fromRGBO(7, 36, 131, 0.75),
                      thumbColor: const Color(0xff1640c9),
                      thickness: 14,
                      thumbVisibility: true,
                      trackVisibility: true,
                      controller: scrollController,
                      child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                              padding: const EdgeInsets.only(right: 17),
                              child: HtmlWidget(element.outerHtml,
                                  textStyle: const TextStyle(
                                      color: PanelStyles.textColor,
                                      fontSize: 18,
                                      fontVariations: [FontVariation.weight(600)]),
                                  customStylesBuilder: (element) => {'font-size': '0.93em'})))));
            }
            return null;
          },
        );
      } else if (controller.error.value) {
        return Center(
            child: Text('news_error'.tr,
                style: const TextStyle(
                    color: PanelStyles.textColor,
                    fontVariations: [FontVariation.weight(700)],
                    fontSize: 18)));
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

    return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: PanelStyles.borderFocusColor))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(title,
                style: TextStyle(
                    color: color, fontVariations: const [FontVariation.weight(700)], fontSize: 18)),
            Text(date,
                style: TextStyle(color: color, fontVariations: const [FontVariation.weight(700)]))
          ],
        ));
  }
}

class NewsContentController extends GetxController {
  NewsContentController() {
    getLastestNews();
  }
  var content = <String, dynamic>{}.obs;
  var error = false.obs;

  void getLastestNews() async {
    API.inst.get('news').then((res) {
      if (res.statusCode == 200) {
        content.value = jsonDecode(res.body);
      }
    }).catchError((e) {
      error.value = true;
    });
  }

  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
