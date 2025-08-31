import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:skribbl_client/models/game/state/draw/draw_state_result.dart';
import 'package:skribbl_client/models/game/state/draw/game_result.dart';
import 'package:skribbl_client/models/models.dart';

import 'package:get/get.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/draw_widget.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/manager.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/utils.dart';

part 'performer.dart';
part 'widgets.dart';

abstract class DrawState {
  static GameState init({required dynamic data}) {
    return data['player_id'] != MePlayer.inst.id
        ? SpectatorDrawState(data: data)
        : data['word_mode'] == _HiddenHintStatus.value
            ? _PerformerDrawState(data: data)
            : _EmittingPerformerDrawState(data: data);
  }
}

mixin DrawStateMixin on GameState {
  Map get points => data['points'];

  String get hint => data['hint'];

  List<dynamic> get likedBy => data['liked_by'];

  @override
  Widget get topWidget => Obx(() => _topWidgetController.child.value);

  final _TopWidgetController _topWidgetController = _TopWidgetController();

  bool get isHintHidden => data['word_mode'] == _HiddenHintStatus.value;

  @override
  Future<void> onStart(Duration sinceStartDate) async {
    Get.find<GameClockController>()
        .start(Duration(seconds: Game.inst.settings['draw_time']) - sinceStartDate);
  }

  Duration get waitDuration => const Duration(seconds: 3);

  @override
  Future<Duration> onEnd(Duration sinceEndDate) async {
    Get.find<GameClockController>().cancel();
    var topWidget = Get.find<TopWidgetController>();
    // word reveal

    DrawStateResult.init().then((widget) => _topWidgetController.child.value = widget);
    if (endState == 'end_game') {
      GameResult.init();
    }

    //#region FORWARD BACKGROUND
    if (sinceEndDate < TopWidgetController.backgroundDuration) {
      await topWidget.forwardBackground(
          from: sinceEndDate / TopWidgetController.backgroundDuration);
      sinceEndDate = Duration.zero;
    } else {
      topWidget.background = 1;
      sinceEndDate -= TopWidgetController.backgroundDuration;
    }
    //#endregion

    //#region FORWARD WORD REVEAL
    if (sinceEndDate < TopWidgetController.contentDuration) {
      await topWidget.contentController
          .forward(from: sinceEndDate / TopWidgetController.contentDuration);
      sinceEndDate = Duration.zero;
    } else {
      topWidget.contentController.value = 1;
      sinceEndDate -= TopWidgetController.contentDuration;
    }
    //#endregion

    //#region WAIT
    if (sinceEndDate < waitDuration) {
      await Future.delayed(waitDuration - sinceEndDate);
      sinceEndDate = Duration.zero;
    } else {
      sinceEndDate -= waitDuration;
    }
    //#endregion

    //#region REVERSE WORD REVEAL
    if (sinceEndDate < TopWidgetController.contentDuration) {
      await topWidget.contentController
          .reverse(from: 1 - sinceEndDate / TopWidgetController.contentDuration);
      sinceEndDate = Duration.zero;
    } else {
      topWidget.contentController.value = 0;
      sinceEndDate -= TopWidgetController.contentDuration;
    }
    //#endregion

    if (endState == 'end_game') {
      //#region FORWARD GAME RESULT
      if (sinceEndDate < TopWidgetController.contentDuration) {
        GameResult.completer!.future.then((widget) => _topWidgetController.child.value = widget);
        await topWidget.contentController
            .forward(from: sinceEndDate / TopWidgetController.contentDuration);
        sinceEndDate = Duration.zero;
      } else {
        topWidget.contentController.value = 1;
        sinceEndDate -= TopWidgetController.contentDuration;
      }
      //#endregion

      //#region WAIT
      if (sinceEndDate < waitDuration) {
        await Future.delayed(waitDuration - sinceEndDate);
        sinceEndDate = Duration.zero;
      } else {
        sinceEndDate -= waitDuration;
      }
      //#endregion

      //#region REVERSE GAME RESULT
      if (sinceEndDate < TopWidgetController.contentDuration) {
        await topWidget.contentController
            .reverse(from: 1 - sinceEndDate / TopWidgetController.contentDuration);
        sinceEndDate = Duration.zero;

        //reset all player score to 0
        for (var player in Game.inst.playersByList) {
          player.score = 0;
        }
        Game.inst.playersByList.refresh();
      } else {
        topWidget.contentController.value = 0;
        sinceEndDate -= TopWidgetController.contentDuration;
      }
      //#endregion

      GameResult.completer = null;
    }

    return sinceEndDate;
  }

  String get performerId => data['player_id'];
  String? get endState => data['end_state']; // end_round | end_game | null
}

class SpectatorDrawState extends GameState with DrawStateMixin {
  SpectatorDrawState({required super.data}) {
    if (!isHintHidden) Get.put(HintController(hint: hint));
  }

  @override
  Widget get status => isHintHidden ? const _HiddenHintStatus() : const _VisibleHintStatus();

  @override
  Future<void> onStart(Duration sinceStartDate) async {
    super.onStart(sinceStartDate);

    Get.find<LikeAndDislikeController>().controller.forward();
  }

  @override
  void Function(String) get submitMessage => _submitMessage;
  late void Function(String) _submitMessage = (text) {
    if (isSending) return;
    isSending = true;

    SocketIO.inst.socket.emitWithAck('player_guess', text, ack: (guessResult) {
      if (guessResult == 'right') {
        // disabled chat when player guess right
        _submitMessage = (_) {};
        return;
      }
      if (guessResult == 'close') {
        if (isCloseHintNotified) return;
        Game.inst.addMessage((color) => MePlayerGuessClose(word: text, backgroundColor: color));
        isCloseHintNotified = true;
      }

      isSending = false;
    });
  };

  /// to reduce server overload
  bool isSending = false;

  bool isCloseHintNotified = false;
}

enum GuessResult {
  right('right'),
  close('close'),
  wrong('wrong');

  final String value;
  const GuessResult(this.value);
}

class HintController extends GetxController {
  HintController({required String hint}) {
    this.hint = hint.obs;
  }
  late RxString hint;

  void setHint(int charIndex, String char) {
    hint.value = hint.value.replaceRange(charIndex, charIndex + 1, char);
  }
}

class _TopWidgetController extends GetxController {
  Rx<Widget> child = (Container() as Widget).obs;
}
