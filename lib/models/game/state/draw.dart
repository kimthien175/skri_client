import 'package:skribbl_client/models/game/game.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/datetime.dart';
import 'package:skribbl_client/utils/socket_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawState extends GameState {
  DrawState({required this.startedAt, required this.playerId, required this.word});

  DrawState.afterChooseWord({required this.startedAt, required this.playerId, required this.word}) {
    afterChooseWord();
  }
  String startedAt;
  String playerId;
  String word;

  void afterChooseWord() async {
    Get.find<MainContentAndFooterController>().child.value =
        playerId == MePlayer.inst.id ? DrawWidget() : DrawViewWidget();

    var durationFromStarted = hasPassed(startedAt);
    Game.inst.remainingTime.start(Game.inst.settings['drawtime'] - durationFromStarted.inSeconds,
        () {
      if (playerId == MePlayer.inst.id) {
        SocketIO.inst.socket.emit('end_draw', 'smt');
      }
    });
  }

  String aboveStatusForGuesser() {
    var game = Game.inst;
    if (game is PrivateGame) {
      if (game.settings['word_mode'] == 'Hidden') {
        return 'WORD_HIDDEN'.tr;
      }
    }
    return 'GUESS_THIS'.tr;
  }

  @override
  Widget get middleStatusOnBar {
    if (playerId == MePlayer.inst.id) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'DRAW_THIS'.tr,
            style: const TextStyle(
                fontFamily: 'Inconsolata', fontVariations: [FontVariation.weight(700)], fontSize: 16),
          ),
          Text(word,
              style: const TextStyle(
                  fontFamily: 'Incosolata', fontVariations: [FontVariation.weight(900)], fontSize: 25.2))
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          aboveStatusForGuesser(),
          style:
              const TextStyle(fontFamily: 'Inconsolata', fontVariations: [FontVariation.weight(700)], fontSize: 16),
        ),
        // SizedBox(
        //     height: 27,
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [],
        //     )),
        Text(word)
      ],
    );
  }

  @override
  Future<void> setup() async {
    afterChooseWord();
  }

  @override
  Future<GameState> next(data) {
    // TODO: implement next
    throw UnimplementedError();
  }

  @override
  void clear() {
    Game.inst.remainingTime.stop();
  }
}
