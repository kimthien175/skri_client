// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:skribbl_client/models/game/state/draw.dart';
import 'package:skribbl_client/models/game/state/match_making.dart';
import 'package:skribbl_client/models/game/state/pick_word.dart';
import 'package:skribbl_client/models/game/state/pre_game.dart';

abstract class GameState {
  GameState({required this.data});

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

  void start();
  Future<void> end(dynamic data);

  String get startedDate => data['started_date'];
  final Map<String, dynamic> data;

  Widget get topWidget;

  bool get isExpired;

  String get status => 'WAITING';
}
