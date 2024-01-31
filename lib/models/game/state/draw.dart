import 'package:cd_mobile/models/game/game.dart';
import 'package:cd_mobile/models/game/player.dart';
import 'package:cd_mobile/models/game/private_game.dart';
import 'package:cd_mobile/models/game/state/game_state.dart';
import 'package:cd_mobile/pages/gameplay/widgets/draw/draw_widget.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content_footer/main_content_footer.dart';
import 'package:cd_mobile/utils/datetime.dart';
import 'package:cd_mobile/utils/socket_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawState extends GameState {
  DrawState({required this.startedAt, required this.playerId, required this.word});

  DrawState.afterChooseWord({required this.startedAt, required this.playerId, required this.word}){
    afterChooseWord();
  }
  String startedAt;
  String playerId;
  String word;

  void afterChooseWord() async {
    Get.find<MainContentAndFooterController>().child.value = DrawWidget();

    var durationFromStarted = hasPassed(startedAt);
    Game.inst.remainingTime.start(Game.inst.settings['drawtime'] - durationFromStarted.inSeconds, (){
      if (playerId == MePlayer.inst.id){
        SocketIO.inst.socket.emit('end_draw','smt');
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
                fontFamily: 'Inconsolata', fontWeight: FontWeight.w700, fontSize: 16),
          ),
          Text(word,
              style: const TextStyle(
                  fontFamily: 'Incosolata', fontWeight: FontWeight.w900, fontSize: 25.2))
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          aboveStatusForGuesser(),
          style:
              const TextStyle(fontFamily: 'Inconsolata', fontWeight: FontWeight.w700, fontSize: 16),
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
}