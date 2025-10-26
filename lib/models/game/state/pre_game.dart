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

  String get hostPlayerId => data['player_id'];
  set hostPlayerId(String value) => data['player_id'] = value;
}
