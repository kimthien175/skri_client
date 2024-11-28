import 'package:skribbl_client/models/game/private_game.dart';
import 'package:skribbl_client/widgets/hover_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatePrivateRoomButton extends StatelessWidget {
  const CreatePrivateRoomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HoverButton(
        height: 40,
        onTap: PrivateGame.host,
        color: const Color(0xff2c8de7),
        hoverColor: const Color(0xff1671c5),
        child: Text('create_private_room_button'.tr,
            style: const TextStyle(fontSize: 19.2, fontVariations: [FontVariation.weight(700)])));
  }
}
