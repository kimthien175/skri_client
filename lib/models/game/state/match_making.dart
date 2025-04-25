import 'package:flutter/material.dart';
import 'package:skribbl_client/models/game/state/state.dart';

class MatchMakingState extends GameState {
  MatchMakingState({required super.data});

  @override
  // TODO: implement topWidget
  Widget get topWidget => throw UnimplementedError();

  @override
  Future<Duration> onEnd(Duration sinceEndDate) {
    // TODO: implement onEnd
    throw UnimplementedError();
  }

  @override
  Future<void> onStart(Duration sinceStartDate, {bool freshStart = false}) {
    // TODO: implement onStart
    throw UnimplementedError();
  }
}
