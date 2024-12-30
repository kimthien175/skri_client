import 'package:flutter/material.dart';
import 'package:skribbl_client/models/game/game.dart';
import 'package:skribbl_client/models/game/state/state.dart';

import 'package:skribbl_client/pages/gameplay/widgets/draw_view/draw_view.dart';

import 'package:get/get.dart';

class DrawState extends GameState {
  DrawState({required super.data});

  // DrawState.afterChooseWord({required this.startedAt, required this.playerId, required this.word}) {
  //   afterChooseWord();
  // }
  String get playerId => data['player_id'];
  String get word => data['word'];

  bool get isSpectator => playerId != MePlayer.inst.id;

  @override
  Widget get topWidget => throw UnimplementedError();

  // void afterChooseWord() async {
  //   var durationFromStarted = hasPassed(startedDate);
  //   Game.inst.remainingTime.start(Game.inst.settings['drawtime'] - durationFromStarted.inSeconds,
  //       () {
  //     if (playerId == MePlayer.inst.id) {
  //       SocketIO.inst.socket.emit('end_draw', 'smt');
  //     }
  //   });
  // }

  // String aboveStatusForGuesser() {
  //   var game = Game.inst;
  //   if (game is PrivateGame) {
  //     if (game.settings['word_mode'] == 'Hidden') {
  //       return 'WORD_HIDDEN'.tr;
  //     }
  //   }
  //   return 'GUESS_THIS'.tr;
  // }

  // @override
  // Widget get middleStatusOnBar {
  //   if (playerId == MePlayer.inst.id) {
  //     return Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Text(
  //           'DRAW_THIS'.tr,
  //           style: const TextStyle(
  //               fontFamily: 'Inconsolata',
  //               fontVariations: [FontVariation.weight(700)],
  //               fontSize: 16),
  //         ),
  //         Text(word,
  //             style: const TextStyle(
  //                 fontFamily: 'Incosolata',
  //                 fontVariations: [FontVariation.weight(900)],
  //                 fontSize: 25.2))
  //       ],
  //     );
  //   }
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Text(
  //         aboveStatusForGuesser(),
  //         style: const TextStyle(
  //             fontFamily: 'Inconsolata', fontVariations: [FontVariation.weight(700)], fontSize: 16),
  //       ),
  //       // SizedBox(
  //       //     height: 27,
  //       //     child: Row(
  //       //       mainAxisSize: MainAxisSize.min,
  //       //       children: [],
  //       //     )),
  //       Text(word)
  //     ],
  //   );
  // }

  @override
  void start() {
    // LIKE_DISLIKE BUTTONS
    if (isSpectator) {
      Get.find<DrawViewController>().buttonsController.controller.forward();
    }

    // CLOCK
    //  Game.inst.remainingTime.start(remainingTime, onDone)
  }

  @override
  Future<void> end(dynamic data) async {}

  @override
  // TODO: implement isExpired
  bool get isExpired => throw UnimplementedError();
}
