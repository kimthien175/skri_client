import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/game/game.dart';
import 'package:skribbl_client/models/game/state/pick_word.dart';
import 'package:skribbl_client/pages/gameplay/gameplay.dart';

import 'state.dart';

class PreGameState extends GameState {
  PreGameState({required super.data}) {
    Get.lazyPut(() => GameSettingsController());
  }

  @override
  Widget get topWidget => const GameSettingsWidget();

  @override
  Future<void> end(dynamic data) async {
    await Get.find<TopWidgetController>().contentController.reverse();

    Game.inst.state.value = PickWordState(data: data);
  }

  @override
  void start() {
    var difference = DateTime.now().difference(DateTime.parse(data['started_at']));
    Get.find<TopWidgetController>().show(difference);
  }

  @override
  // TODO: implement isExpired
  bool get isExpired => throw UnimplementedError();

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
