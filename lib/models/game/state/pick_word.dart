import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/socket_io.dart';

class PickWordState extends GameState {
  Duration get _fullPickingDuration => Duration(seconds: Game.inst.system['pick_word_time']);
  PickWordState({required super.data});

  String get playerId => data['player_id'];
  List<String> get words => data['words'];
  bool get isPicker => MePlayer.inst.id == playerId;

  @override
  Widget get topWidget => roundNotify != null ? _topWidgetRoundNotify : _topWidgetChooseWord;

  Widget get _topWidgetRoundNotify =>
      Text('round_noti'.trParams({'round': Game.inst.currentRound.value.toString()}).toUpperCase(),
          style: TextStyle(color: Colors.white));

  Widget get _topWidgetChooseWord =>
      Text('PLAYER CHOOSE WORD', style: TextStyle(color: Colors.white));

  late int? roundNotify = data['round_notify'];

  void changeTopWidget() {
    roundNotify = null;
    Game.inst.state.refresh();
  }

  @override
  Future<void> onStart(Duration sinceStartDate) async {
    var topWidget = Get.find<TopWidgetController>();
    assert(topWidget.backgroundController.value == 1);

    //#region ROUND NOTI
    if (roundNotify != null) {
      // show round intro
      if (sinceStartDate < TopWidgetController.contentDuration) {
        await topWidget.contentController
            .forward(from: sinceStartDate / TopWidgetController.contentDuration);
        sinceStartDate = Duration.zero;
      } else {
        sinceStartDate -= TopWidgetController.contentDuration;
      }

      // hold round intro for 1s - contentDuration
      if (sinceStartDate < _roundNotiDuration) {
        topWidget.contentController.value = 1;
        await Future.delayed(const Duration(seconds: 1) - sinceStartDate);
        sinceStartDate = Duration.zero;
      } else {
        sinceStartDate -= _roundNotiDuration;
      }

      // close up round noti
      if (sinceStartDate < TopWidgetController.contentDuration) {
        await topWidget.contentController
            .reverse(from: 1 - sinceStartDate / TopWidgetController.contentDuration);
        sinceStartDate = Duration.zero;
      } else {
        sinceStartDate -= TopWidgetController.contentDuration;
      }

      changeTopWidget();
    }
    //#endregion

    if (sinceStartDate < TopWidgetController.contentDuration) {
      await topWidget.contentController
          .forward(from: sinceStartDate / TopWidgetController.contentDuration);
      sinceStartDate = Duration.zero;
    } else {
      sinceStartDate -= TopWidgetController.contentDuration;
      topWidget.contentController.value = 1;
    }

    Get.find<GameClockController>().start(_fullPickingDuration - sinceStartDate, onEnd: () {
      // send random word
      if (isPicker && _wordStatus == _WordSendingStatus.notSent) {
        sendWord(words[Random().nextInt(words.length)]);
      }
    });
  }

  Duration get _roundNotiDuration => const Duration(seconds: 1);

  void chooseWord(String word) {
    if (_wordStatus == _WordSendingStatus.notSent) {
      sendWord(word);
    }
  }

  void sendWord(String word) {
    _wordStatus = _WordSendingStatus.sending;
    SocketIO.inst.socket.emit('pick_word', word);
  }

  _WordSendingStatus _wordStatus = _WordSendingStatus.notSent;

  @override
  Future<Duration> onEnd(Duration sinceEndDate) {
    // TODO: implement onEnd
    throw UnimplementedError();
  }
}

enum _WordSendingStatus { notSent, sending }
