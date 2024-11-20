import 'package:skribbl_client/pages/home/home.dart';
import 'package:skribbl_client/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:skribbl_client/models/game/game.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onTap: () {
        var homeController = Get.find<HomeController>();

        _dialog.show();
        return;

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

        //otherwise join public game
        PublicGame.join();
      },
      color: const Color(0xff53e237),
      hoverColor: const Color(0xff38c41c),
      height: 54,
      child: Text('play_button'.tr,
          style: const TextStyle(
              fontSize: 32, shadows: [Shadow(color: Color(0x2b000000), offset: Offset(2, 2))])),
    );
  }

  static GameDialog? __dialog;
  // TODO: SHOW DIALOG FOR INVALID PRIVATE ROOM CODE
  static GameDialog get _dialog => __dialog ??= _WrongPrivateCodeDialog();
}

class _WrongPrivateCodeDialog extends GameDialog {
  _WrongPrivateCodeDialog()
      : super(
            title: () => 'dialog_title_error'.tr,
            content: Column(children: [
              Text('dialog_content_wrong_private_code'.tr),
              HoverButton(onTap: () => _WrongPrivateCodeDialog().show(), child: Text('add overlay'))
            ]));
}
