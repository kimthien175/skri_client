library;

export 'game_result.dart';
export 'draw_state_result.dart';

import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/utils.dart';

part 'performer.dart';
part 'widgets.dart';

mixin DrawStateMixin on GameState {
  Map get points => data['points'];

  String get hint => data['hint'];

  List get likedBy => data['liked_by'] as List;

  bool get isHintHidden => data['word_mode'] == HiddenHintStatus.value;

  /// START CLOCK
  @override
  Future<DateTime> onStart(DateTime startDate) async {
    var drawDuration = Duration(seconds: Game.inst.settings['draw_time']) - startDate.fromNow();
    if (drawDuration > Duration.zero) {
      Get.find<GameClockController>().start(drawDuration);
    }

    return startDate;
  }

  /// CANCEL CLOCK
  ///
  /// (SHOW GAME RESULT IF ENDGAME IN EMERGENCY)
  ///
  /// SHOW WORD, SHOW GAME RESULT IF NEEDED
  @override
  Future<DateTime> onEnd(DateTime endDate) async {
    if (Game.inst.status['bonus']['end_state'] == null) return super.onEnd(endDate);

    var topWidget = Get.find<TopWidgetController>();

    // word reveal
    DrawStateResult.init().then((widget) => topWidget.child.value = widget);

    var sinceEndDate = DateTime.now() - endDate;

    //#region FORWARD BACKGROUND
    if (sinceEndDate < TopWidgetController.backgroundDuration) {
      //play sound
      Sound.inst.play(this is SpectatorDrawState && !(this as SpectatorDrawState).isGuessRight
          ? Sound.inst.roundEndFailure
          : Sound.inst.roundEndSuccess);

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
      await topWidget.forwardContent(from: sinceEndDate / TopWidgetController.contentDuration);
      sinceEndDate = Duration.zero;
    } else {
      topWidget.content = 1;
      sinceEndDate -= TopWidgetController.contentDuration;
    }
    //#endregion

    //#region WAIT
    if (sinceEndDate < waitDuration) {
      await topWidget.wait(waitDuration - sinceEndDate);
      sinceEndDate = Duration.zero;
    } else {
      sinceEndDate -= waitDuration;
    }
    //#endregion

    //#region REVERSE WORD REVEAL
    if (sinceEndDate < TopWidgetController.contentDuration) {
      await topWidget.reverseContent(from: 1 - sinceEndDate / TopWidgetController.contentDuration);
      sinceEndDate = Duration.zero;
    } else {
      topWidget.content = 0;
      sinceEndDate -= TopWidgetController.contentDuration;
    }
    //#endregion

    var afterWordRevealDate = endDate.add(TopWidgetController.contentDuration * 2 +
        waitDuration +
        TopWidgetController.backgroundDuration);
    if (Game.inst.endGameData != null) return super.onEnd(afterWordRevealDate);
    return afterWordRevealDate;
  }

  String get performerId => data['player_id'];
}

class SpectatorDrawState extends GameState with DrawStateMixin {
  SpectatorDrawState({required super.data}) {
    if (!isHintHidden) Get.find<HintController>().newHint(hint);
  }

  @override
  Widget get status => isHintHidden ? const HiddenHintStatus() : const _VisibleHintStatus();

  @override
  Future<DateTime> onStart(DateTime startDate) async {
    var likeController = Get.find<LikeAndDislikeController>();

    var sinceDate = DateTime.now() - startDate;
    if (sinceDate < likeController.duration) {
      likeController.controller.forward(from: sinceDate / likeController.duration);
    } else {
      likeController.controller.value = 1;
    }

    return super.onStart(startDate);
  }

  @override
  void onClose() {
    Get.find<LikeAndDislikeController>().controller.value = 0;
  }

  bool get isGuessRight => _submitMessage == null;

  @override
  void Function(String) get submitMessage => _submitMessage ?? (_) {};
  late void Function(String)? _submitMessage = (text) {
    if (isSending) return;
    isSending = true;

    SocketIO.inst.socket.emitWithAck('player_guess', text, ack: (guessResult) {
      if (guessResult == 'right') {
        // disabled chat when player guess right
        _submitMessage = null;
        Sound.inst.play(Sound.inst.guessedRight);
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
  HintController();
  final RxString _hint = ''.obs;

  String get hint => _hint.value;

  void newHint(String hint) {
    _hint.value = hint;
  }

  void setHint(int charIndex, String char) {
    _hint.value = _hint.value.replaceRange(charIndex, charIndex + 1, char);
  }
}
