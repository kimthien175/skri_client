import 'package:cd_mobile/models/gif_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: () {
              Get.offAllNamed('/home');
            },
            child: GifManager.inst.misc('logo').widgetWithShadow()));
  }
}
