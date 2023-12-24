import 'package:cd_mobile/models/gif_manager.dart';
import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo(this.onPressed, {super.key});
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: onPressed,
            child: GifManager.inst.misc('logo').widgetWithShadow()));
  }
}
