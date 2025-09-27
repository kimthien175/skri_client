library;

export './draw/draw.dart';
export './public_lobby.dart';
export './pick_word.dart';
export './pre_game.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/utils.dart';

abstract class GameState {
  GameState({required this.data});

  String get id => data['id'];

  /// parse state from server
  factory GameState.fromJSON(dynamic data) {
    switch (data['type']) {
      // from server || client create
      case 'pre_game':
        return PreGameState(data: data);
      // from server || client create
      case 'pick_word':
        return PickWordState(data: data);

      case 'draw':
        if (data['player_id'] != MePlayer.inst.id) return SpectatorDrawState(data: data);
        if (data['word_mode'] == HiddenHintStatus.value) return PerformerDrawState(data: data);
        return EmittingPerformerDrawState(data: data);

      case 'public_lobby':
        return PublicLobbyState(data: data);
      default:
        throw Exception('Unimplemented game state');
    }
  }

  Future<DateTime> onStart(DateTime startDate);

  Duration get waitDuration => const Duration(seconds: 3);

  TopWidgetController get topWidgetController => Get.find<TopWidgetController>();

  /// if the onStart animation is running, cancel it
  /// return the time-based logic onStart is running or not
  //

  /// show end game data
  Future<DateTime> onEnd(DateTime endDate) async {
    topWidgetController.background = 1;

    var sinceEndDate = endDate.fromNow();

    //#region FORWARD GAME RESULT
    if (sinceEndDate < TopWidgetController.contentDuration) {
      await GameResult.completer!.future.then((widget) => topWidgetController.child.value = widget);
      await topWidgetController.forwardContent(
          from: sinceEndDate / TopWidgetController.contentDuration);

      sinceEndDate = Duration.zero;
    } else {
      topWidgetController.content = 1;
      sinceEndDate -= TopWidgetController.contentDuration;
    }
    //#endregion

    //#region WAIT
    if (sinceEndDate < waitDuration) {
      await topWidgetController.wait(waitDuration - sinceEndDate);
      sinceEndDate = Duration.zero;
    } else {
      sinceEndDate -= waitDuration;
    }
    //#endregion

    //#region REVERSE GAME RESULT
    if (sinceEndDate < TopWidgetController.contentDuration) {
      await topWidgetController.reverseContent(
          from: 1 - sinceEndDate / TopWidgetController.contentDuration);

      GameResult.completer = null;

      //reset all player score to 0
      Game.inst.playersByMap.forEach((key, value) => value.score = 0);
      Get.find<PlayersListController>().list.refresh();
    } else {
      topWidgetController.content = 0;
    }
    //#endregion

    return endDate.add(TopWidgetController.contentDuration * 2 + waitDuration);
  }

  final Map<String, dynamic> data;

  Widget get status => Builder(builder: (_) => Text('WAITING'.tr));

  ///only DrawState for performer can override this
  final Widget canvas = const DrawViewWidget();

  /// only DrawState can override this
  void Function(String) get submitMessage =>
      (String text) => SocketIO.inst.socket.emit('player_chat', text);

  void onClose();
}
