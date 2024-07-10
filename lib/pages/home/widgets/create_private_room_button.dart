import 'package:skribbl_client/models/game/private_game.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/hover_button.dart';
import 'package:skribbl_client/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatePrivateRoomButton extends StatelessWidget {
  const CreatePrivateRoomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HoverButton(
        height: 40,
        onTap: () {
          // set home to loading state
          LoadingOverlay.inst.show();
          // init private room
          PrivateGame.host();
        },
        borderRadius: GlobalStyles.borderRadius,
        color: const Color(0xff2c8de7),
        hoverColor: const Color(0xff1671c5),
        child: Text('create_private_room_button'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: PanelStyles.textColor,
                fontSize: 19.2,
                fontWeight: FontWeight.w700,
                shadows: [GlobalStyles.textShadow])));
  }
}
