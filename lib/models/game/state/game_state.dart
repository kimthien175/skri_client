import 'package:cd_mobile/models/game/state/draw.dart';
import 'package:cd_mobile/models/game/state/start_round.dart';
import 'package:cd_mobile/models/game/state/wait_for_setup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class GameState {
  /// player join room from middle game
  static GameState fromJSON(dynamic rawGameState) {
    switch (rawGameState['type']) {
      case 'waitForSetup':
        return WaitForSetupState();
      case 'startRound':
        return StartRoundState(
            wordOptions: rawGameState['word_options'],
            playerId: rawGameState['playerId'],
            startedAt: rawGameState['startedAt']);
      case 'draw':
        return DrawState(
            playerId: rawGameState['playerId'],
            startedAt: rawGameState['startedAt'],
            word: rawGameState['word']);
            
      case 'chooseWord':
        return ChooseWordState(
            playerId: rawGameState['playerId'],
            startedAt: DateTime.parse(rawGameState['startedAt']));
      case 'drawResult':
        return DrawResultState(word: rawGameState['word']);
      case 'gameResult':
        return GameResultState();
      default:
        return MatchMakingState();
    }
  }

  Future<GameState> next(dynamic data);

  Widget get middleStatusOnBar => Text(
        'WAITING'.tr,
        style:
            const TextStyle(fontFamily: 'Inconsolata', fontWeight: FontWeight.w700, fontSize: 16),
      );

  Future<void> setup();
}

class ChooseWordState extends GameState {
  ChooseWordState({required this.playerId, required this.startedAt});
  final String playerId;
  final DateTime startedAt;
  @override
  Future<void> setup() {
    // TODO: implement setup
    throw UnimplementedError();
  }

  @override
  Future<GameState> next(data) {
    // TODO: implement next
    throw UnimplementedError();
  }
}

class DrawResultState extends GameState {
  DrawResultState({required this.word});
  final String word;
  @override
  Future<void> setup() {
    // TODO: implement setup
    throw UnimplementedError();
  }

  @override
  Future<GameState> next(data) {
    // TODO: implement next
    throw UnimplementedError();
  }
}

class GameResultState extends GameState {
  @override
  Future<GameState> next(data) {
    // TODO: implement next
    throw UnimplementedError();
  }

  @override
  Future<void> setup() {
    // TODO: implement setup
    throw UnimplementedError();
  }
}

class MatchMakingState extends GameState {
  @override
  Future<void> setup() {
    // TODO: implement setup
    throw UnimplementedError();
  }

  @override
  // TODO: implement middleStatusOnBar
  Widget get middleStatusOnBar => throw UnimplementedError();

  @override
  Future<GameState> next(data) {
    // TODO: implement next
    throw UnimplementedError();
  }
}
