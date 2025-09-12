import 'package:get/get.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/pages/gameplay/gameplay.dart';
import 'package:skribbl_client/utils/datetime.dart';

class PreGameState extends GameState {
  PreGameState({required super.data}) {
    Get.lazyPut(() => GameSettingsController());
  }

  @override
  Future<DateTime> onStart(DateTime startDate) async {
    var sinceStartDate = DateTime.now() - startDate;

    topWidgetController.child.value = const GameSettingsWidget();

    var consumedDuration = TopWidgetController.contentDuration;

    if (Game.inst.stateCommand == 'start') {
      //#region FORWARD BACKGROUND
      if (sinceStartDate < TopWidgetController.backgroundDuration) {
        await topWidgetController.forwardBackground(
            from: sinceStartDate / TopWidgetController.backgroundDuration);

        sinceStartDate = Duration.zero;
      } else {
        topWidgetController.background = 1;
        sinceStartDate -= TopWidgetController.backgroundDuration;
      }
      //#endregion

      consumedDuration += TopWidgetController.backgroundDuration;
    } else {
      // require background
      topWidgetController.background = 1;
    }

    //#region FORWARD CONTENT
    if (sinceStartDate < TopWidgetController.contentDuration) {
      await topWidgetController.forwardContent(
          from: sinceStartDate / TopWidgetController.contentDuration);
    } else {
      topWidgetController.content = 1;
    }
    //#endregion

    return startDate.add(consumedDuration);
  }

  @override
  Future<DateTime> onEnd(DateTime endDate) async {
    if (Game.inst.endGameData != null) return super.onEnd(endDate);

    // required background
    topWidgetController.background = 1;

    var sinceEndDate = DateTime.now() - endDate;
    //#region REVERSE CONTENT
    if (sinceEndDate < TopWidgetController.contentDuration) {
      await topWidgetController.reverseContent(
          from: 1 - sinceEndDate / TopWidgetController.contentDuration);
      sinceEndDate = Duration.zero;
    } else {
      topWidgetController.content = 0;
      sinceEndDate -= TopWidgetController.contentDuration;
    }
    //#endregion

    return endDate.add(TopWidgetController.contentDuration);
  }

  @override
  void onClose() {}

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
