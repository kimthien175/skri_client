import 'package:cd_mobile/models/gif_manager.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class Logo extends StatelessWidget {
  const Logo(this.onPressed, {super.key});
  final Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: onPressed,
            child: GifManager.inst.misc('logo').builder.initShadowedOrigin().doFreezeSize()));
  }

  static void clearUrl() {
    html.window.history.pushState(null, '', '');
  }
}
