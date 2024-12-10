import 'package:flutter/material.dart';
import 'package:skribbl_client/models/game/state/state.dart';

class WordReveal extends GameState {
  WordReveal({required super.startedDate});

  @override
  Future<void> end() async {}

  @override
  void start() {}

  @override
  // TODO: implement topWidget
  Widget get topWidget => throw UnimplementedError();
}
