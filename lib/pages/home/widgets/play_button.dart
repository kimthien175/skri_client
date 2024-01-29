import 'package:cd_mobile/models/game/private_game.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({super.key});

  static String? roomCode;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: () {
              if (roomCode == null) return;

              if (RegExp(r'^[a-z0-9]{4,}$').hasMatch(roomCode!)) {
                print('match');
                Get.find<HomeController>().isLoading.value = true;
                PrivateGame.join(roomCode!);
              } else {
                print('no match');
                showDialog(
                    context: Get.context!,
                    builder: (context) => AlertDialog(
                          title: Text('wrong_private_room_code'.tr),
                        ));
              }
            },
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
