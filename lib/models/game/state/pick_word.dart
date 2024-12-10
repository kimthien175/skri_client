import 'package:flutter/material.dart';
import 'package:skribbl_client/models/game/state/state.dart';

class PickWordState extends GameState {
  PickWordState({required super.startedDate});
  @override
  Future<void> end() {
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

  void chooseWord(String word) {
    // Get.find<TopWidgetController>().controller.reverse();
    // SocketIO.inst.socket.emit('choose_word', word);
  }
}
