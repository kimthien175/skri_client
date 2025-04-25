import 'package:flutter/material.dart';
import 'package:skribbl_client/models/game/state/draw.dart';
import 'package:skribbl_client/models/game/state/match_making.dart';
import 'package:skribbl_client/models/game/state/pick_word.dart';
import 'package:skribbl_client/models/game/state/pre_game.dart';

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
        return DrawState(data: data);

      case 'match_making':
        return MatchMakingState(data: data);
      default:
        throw Exception('Unimplemented game state');
    }
  }

  /// default value of `startedDate` is state.`startedDate`
  Future<void> onStart(Duration sinceStartDate);

  /// `sinceEndDate` always smaller than or equal to `endDuration`
  Future<Duration> onEnd(Duration sinceEndDate);

  final Map<String, dynamic> data;

  Widget get topWidget;

  String get status => 'WAITING';
}
