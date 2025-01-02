import 'package:flutter/material.dart';
import 'package:skribbl_client/models/game/state/state.dart';

class MatchMakingState extends GameState {
  MatchMakingState({required super.data});

  @override
  Future<void> end(data) {
    // TODO: implement end
    throw UnimplementedError();
  }

  @override
  void start() {
    // TODO: implement start
  }

  @override
  // TODO: implement topWidget
  Widget get topWidget => throw UnimplementedError();

  @override
  // TODO: implement isExpired
  bool get isExpired => throw UnimplementedError();
}
