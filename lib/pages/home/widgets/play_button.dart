import 'package:skribbl_client/models/game/private_game.dart';
import 'package:skribbl_client/widgets/hover_button.dart';
import 'package:skribbl_client/widgets/overlay/loading.dart';
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


/*import 'package:skribbl_client/models/game/game.dart';
import 'package:skribbl_client/pages/home/home.dart';
import 'package:skribbl_client/widgets/dialog/dialog.dart';
import 'package:skribbl_client/widgets/hover_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onTap: () {
        var homeController = Get.find<HomeController>();

        if (homeController.hasCode) {
// #region Private room
          if (homeController.isPrivateRoomCodeValid) {
            // join private room
            // TODO: TEST JOINING PRIVATE ROOM
            PrivateGame.join(homeController.privateRoomCode);
            return;
          }
          // show dialog for invalid code room

          _dialog.show();
// #endregion

          return;
        }

        // otherwise join public game
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
            content: Text('dialog_content_wrong_private_code'.tr));
}

class _WrongPrivateCodeWidget extends OverlayWidgetChild<GameDialog> {
  const _WrongPrivateCodeWidget();

  @override
  Widget build(BuildContext context) {
    return Text('dialog_content_wrong_private_code'.tr);
  }
}
*/