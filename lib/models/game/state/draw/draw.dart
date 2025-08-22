import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skribbl_client/models/models.dart';

import 'package:get/get.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/draw_widget.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/manager.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw_view/word_result.dart';
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
  Map<String, int> points = {};

  String get hint => data['hint'];

  @override
  Widget get topWidget => WordResult();

  bool get isHintHidden => data['word_mode'] == _HiddenHintStatus.value;

  @override
  Future<void> onStart(Duration sinceStartDate) async {
    Get.find<GameClockController>().start(
        Duration(seconds: Game.inst.settings['draw_time']) - sinceStartDate,
        onEnd: () => onEnd(Duration.zero));
  }

  @override
  Future<Duration> onEnd(Duration sinceEndDate) async {
    Get.find<GameClockController>().cancel();
    var topWidget = Get.find<TopWidgetController>();
    // word reveal
    if (sinceEndDate < TopWidgetController.backgroundDuration) {
      await topWidget.forwardBackground(
          from: sinceEndDate / TopWidgetController.backgroundDuration);
      sinceEndDate = Duration.zero;
    } else {
      topWidget.background = 1;
      sinceEndDate -= TopWidgetController.backgroundDuration;
    }

    if (sinceEndDate < TopWidgetController.contentDuration) {
      await topWidget.contentController
          .forward(from: sinceEndDate / TopWidgetController.contentDuration);
      return Duration.zero;
    } else {
      topWidget.contentController.value = 1;
      return sinceEndDate - TopWidgetController.contentDuration;
    }
  }
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
