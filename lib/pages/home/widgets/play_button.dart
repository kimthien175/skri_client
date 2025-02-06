import 'package:skribbl_client/models/game/private_game.dart';
import 'package:skribbl_client/pages/home/home.dart';
import 'package:skribbl_client/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onTap: () {
        var homeController = Get.find<HomeController>();

        if (homeController.hasCode) {
//#region Private room
          if (homeController.isPrivateRoomCodeValid) {
            // join private room
            //TODO: TEST JOINING PRIVATE ROOM
            PrivateGame.join(homeController.privateRoomCode);
            return;
          }
          // show dialog for invalid code room

          _dialog.show();
//#endregion

          return;
        }

//         //otherwise join public game
//         PublicGame.join();
      },
      color: const Color(0xff53e237),
      hoverColor: const Color(0xff38c41c),
      height: 54,
      child: Text('play_button'.tr, style: const TextStyle(fontSize: 32)),
    );
  }

  static GameDialog? __dialog;
  static GameDialog get _dialog => __dialog ??= GameDialog.error(
      content:
          Center(child: Builder(builder: (ct) => Text('dialog_content_wrong_private_code'.tr))));
}
