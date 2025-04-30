import 'package:skribbl_client/models/gif_manager.dart';
import 'package:flutter/material.dart';

import 'package:web/web.dart' as web;

class Logo extends StatelessWidget {
  const Logo(this.onPressed, {super.key});
  final Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: onPressed, child: GifManager.inst.misc('logo').builder.initWithShadow()));
  }

  static void clearUrl() {
    web.window.history.pushState(null, '', '');
  }
}
