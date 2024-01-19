import 'package:cd_mobile/models/game_play/owned_private_game.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatePrivateRoomButton extends StatelessWidget {
  const CreatePrivateRoomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: () {
              // set home to loading state
              Get.find<HomeController>().isLoading.value = true;
              // init private room
              OwnedPrivateGame.init();
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xff2c8de7),
                borderRadius: GlobalStyles.borderRadius,
              ),
              constraints: const BoxConstraints.expand(height: 40),
              child: Text('create_private_room_button'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: PanelStyles.textColor,
                      fontSize: 19.2,
                      fontWeight: FontWeight.w700,
                      shadows: [GlobalStyles.textShadow])),
            )));
  }
}
