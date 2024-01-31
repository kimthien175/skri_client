import 'package:cd_mobile/models/game/player.dart';
import 'package:cd_mobile/models/game/state/game_state.dart';
import 'package:cd_mobile/models/game/state/start_round.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content_footer/main_content_footer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaitForSetupState extends GameState {
  @override
  Future<void> setup() async {
    Get.find<MainContentAndFooterController>().showSettings();
  }

  @override
  Widget get middleStatusOnBar => Center(
          child: Text(
        'WAITING'.tr,
        style:
            const TextStyle(fontFamily: 'Inconsolata', fontWeight: FontWeight.w700, fontSize: 16),
      ));

  @override
  Future<GameState> next(dynamic data) async {
    // Host did reverse the old widget, remaining guests
    if (!(MePlayer.inst.isOwner == true)) {
      await Get.find<MainContentAndFooterController>().clearCanvasAndHideTopWidget();
    }
    return StartRoundState.afterWaitForSetup(
        wordOptions: data['word_options'],
        playerId: data['player_id'],
        startedAt: data['started_at']);
  }
}
