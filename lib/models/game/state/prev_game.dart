// import 'package:skribbl_client/models/models.dart';
// import 'package:skribbl_client/pages/gameplay/gameplay.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:skribbl_client/pages/gameplay/widgets/draw/draw_widget.dart';

// import 'start_round.dart';
// import 'state.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/pages/gameplay/gameplay.dart';

import 'state.dart';

class PrevGameState extends GameState {
  PrevGameState({super.cachedNextState, required super.startedDate}) {
    Get.put(GameSettingsController());
  }

  @override
  Widget get topWidget => const GameSettings();

  @override
  Future<void> end() {
    // TODO: implement end
    throw UnimplementedError();
  }

  @override
  void start() {
    Get.find<TopWidgetController>().show();
  }

  // @override
  // Future<void> setup() async {
  //   //Get.find<MainContentAndFooterController>().child.value = const DrawWidget();
  // }

  // @override
  // Widget get middleStatusOnBar => Center(
  //         child: Text(
  //       'WAITING'.tr,
  //       style: const TextStyle(
  //           fontFamily: 'Inconsolata', fontVariations: [FontVariation.weight(700)], fontSize: 16),
  //     ));

  // @override
  // Future<GameState> next(dynamic data) async {
  //   // Host did reverse the old widget, remaining guests
  //   if (!(MePlayer.inst.isOwner == true)) {
  //     //await Get.find<MainContentAndFooterController>().clearCanvasAndHideTopWidget();
  //   }
  //   return StartRoundState.afterWaitForSetup(
  //       wordOptions: data['word_options'],
  //       playerId: data['player_id'],
  //       startedAt: data['started_at']);
  // }
}
