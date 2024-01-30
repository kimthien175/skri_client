import 'package:cd_mobile/models/game/player.dart';
import 'package:cd_mobile/models/game/state/game_state.dart';
import 'package:cd_mobile/pages/gameplay/widgets/footer.dart';
import 'package:cd_mobile/pages/gameplay/widgets/invite_section.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content/main_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaitForSetupState extends GameState {
  @override
  void setup() {
    Get.find<MainContentController>().showSettings(isCovered: !(MePlayer.inst.isOwner == true));
    Get.find<GameFooterController>().child.value = const InviteSection();
  }

  @override
  Widget get middleStatusOnBar => Center(
          child: Text(
        'WAITING'.tr,
        style:
            const TextStyle(fontFamily: 'Inconsolata', fontWeight: FontWeight.w700, fontSize: 16),
      ));
}
