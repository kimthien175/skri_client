import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsContent extends StatelessWidget {
  const NewsContent({super.key});

  Future<String> getLastestNews() async {
    final httpClient = http.Client();

    final res = await httpClient.get(Uri.parse('http://127.0.0.1:4000/news'));

    if (res.statusCode == 200) {
      return res.body;
    }

    throw Exception("Can't get lastest news");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getLastestNews(),
        builder: (context, snapshots) {
          if (snapshots.hasData) {
            var htmlString = utf8.decode(base64Decode(snapshots.data!));

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
                              child: HtmlWidget(
                                element.outerHtml,
                                textStyle: TextStyle(
                                    color: PanelStyles.textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                                customStylesBuilder: (element) {
                                  // TODO
                  return {
                    'font-size': '0.93em'
                  };
                                },
                              ))));
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

class _Content extends StatelessWidget {
  const _Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
