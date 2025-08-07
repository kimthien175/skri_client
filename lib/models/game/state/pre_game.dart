import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/pages/gameplay/gameplay.dart';
import 'package:skribbl_client/utils/datetime.dart';

class PreGameState extends GameState {
  PreGameState({required super.data}) {
    Get.lazyPut(() => GameSettingsController());
  }

  @override
  Widget get topWidget => const GameSettingsWidget();

  @override
  Future<void> onStart(Duration sinceStartDate) async {
    var widgetController = Get.find<TopWidgetController>();

    if (Game.inst.stateCommand == Game.start) {
      // do background
      if (sinceStartDate < TopWidgetController.backgroundDuration) {
        await widgetController.forwardBackground(
            from: sinceStartDate / TopWidgetController.backgroundDuration);

        sinceStartDate = Duration.zero;
      } else {
        widgetController.background = 1;
        sinceStartDate -= TopWidgetController.backgroundDuration;
      }
    }

    if (sinceStartDate < TopWidgetController.contentDuration) {
      await widgetController.contentController
          .forward(from: sinceStartDate / TopWidgetController.contentDuration);
    } else {
      widgetController.contentController.value = 1;
    }
  }

  @override
  Future<Duration> onEnd(Duration sinceEndDate) async {
    var controller = Get.find<TopWidgetController>().contentController;
    if (sinceEndDate < TopWidgetController.contentDuration) {
      await controller.reverse(from: 1 - sinceEndDate / TopWidgetController.contentDuration);
      return Duration.zero;
    } else {
      controller.value = 0;
      return sinceEndDate - TopWidgetController.contentDuration;
    }
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
