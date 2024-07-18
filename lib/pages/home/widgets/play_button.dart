import 'package:skribbl_client/models/game/private_game.dart';
import 'package:skribbl_client/widgets/hover_button.dart';
import 'package:skribbl_client/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({super.key});

  static String? roomCode;

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onTap: () {
        if (roomCode == null) return;

        if (RegExp(r'^[a-z0-9]{4,}$').hasMatch(roomCode!)) {
          LoadingOverlay.inst.show();
          PrivateGame.join(roomCode!);
        } else {
          showDialog(
              context: Get.context!,
              builder: (context) => AlertDialog(
                    title: Text('wrong_private_room_code'.tr),
                  ));
        }
      },
      color: const Color(0xff53e237),
      hoverColor: const Color(0xff38c41c),
      height: 54,
      child: Text('play_button'.tr,
          style: const TextStyle(
              fontSize: 32, shadows: [Shadow(color: Color(0x2b000000), offset: Offset(2, 2))])),
    );
  }
}
