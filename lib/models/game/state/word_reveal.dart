import 'package:flutter/material.dart';
import 'package:skribbl_client/models/game/state/state.dart';

class WordReveal extends GameState {
  WordReveal({required super.data});

  @override
  Future<void> end(dynamic data) async {}

  @override
  void start() {}

  @override
  Widget get topWidget => throw UnimplementedError();

  @override
  // TODO: implement isExpired
  bool get isExpired => throw UnimplementedError();
}
