import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints.expand(height: 54),
        child: TextButton(
            style: ButtonStyle(
                backgroundColor: const MaterialStatePropertyAll(Color(0xff53e237)),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: GlobalStyles.borderRadius,
                ))),
            onPressed: () => Get.find<HomeController>().isLoading.value = true,
            child: Text('play_button'.tr,
                style: TextStyle(
                    fontSize: 32,
                    color: PanelStyles.textColor,
                    fontWeight: FontWeight.w800,
                    shadows: [GlobalStyles.textShadow]))));
  }
}
