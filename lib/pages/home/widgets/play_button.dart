import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: () {},
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xff53e237),
                borderRadius: GlobalStyles.borderRadius,
              ),
              constraints: const BoxConstraints.expand(height: 54),
              child: Text('play_button'.tr,
                  style: TextStyle(
                      fontSize: 32,
                      color: PanelStyles.textColor,
                      fontWeight: FontWeight.w800,
                      shadows: [GlobalStyles.textShadow])),
            )));
  }
}
