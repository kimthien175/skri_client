import 'dart:math';

import 'package:cd_mobile/models/game/game.dart';
import 'package:cd_mobile/models/game/player.dart';
import 'package:cd_mobile/models/game/state/draw.dart';
import 'package:cd_mobile/models/game/state/game_state.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content_footer/main_content_footer.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content_footer/overlay.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content_footer/top_widget.dart';
import 'package:cd_mobile/utils/datetime.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// notify round, show player choosing word
class StartRoundState extends GameState {
  StartRoundState({required this.wordOptions, required this.playerId, required this.startedAt}) {
    playerName = Game.inst.playersByMap[playerId]!.name;
  }

  StartRoundState.afterWaitForSetup(
      {required this.wordOptions, required this.playerId, required this.startedAt}) {
    playerName = Game.inst.playersByMap[playerId]!.name;
    afterWaitForSetup();
  }

  String playerId;
  late String playerName;
  String startedAt;
  List<dynamic> wordOptions; // List<String> deal later

  void afterWaitForSetup() async {
    var durationFromStarted = hasPassed(startedAt);

    // FORWARD ROUND NOTI AND REVERSE, FORWARD PLAYER CHOOSE WORD
    if (durationFromStarted <= MainContentAndFooter.animationDuration) {
      whenRoundNotiForward(durationFromStarted);
      return;
    }

    // JUST REVERSE ROUND NOTI, FORWARD PLAYER CHOOSE WORD
    if (durationFromStarted <= MainContentAndFooter.animationDuration * 2) {
      whenRoundNotiReverse(durationFromStarted - MainContentAndFooter.animationDuration);
      return;
    }

    // FORWARD PLAYER CHOOSE WORD
    if (durationFromStarted <= MainContentAndFooter.animationDuration * 3) {
      whenPlayerChooseWordForward(durationFromStarted - MainContentAndFooter.animationDuration * 2);
      return;
    }

    whenPlayerChooseWordShown(durationFromStarted);
  }

  void whenRoundNotiForward(Duration durationFromStarted) async {
    var topWC = Get.find<TopWidgetController>();

    topWC.child.value = const RoundWidget();

    // round noti forward
    await topWC.controller.forward(
        from: durationFromStarted.inMicroseconds /
            MainContentAndFooter.animationDuration.inMicroseconds);
    await topWC.controller.reverse();
    topWC.child.value = PlayerChooseWordWidget(wordOptions: wordOptions, remainingTime: 15);

    await topWC.controller.forward();
  }

  void whenRoundNotiReverse(Duration durationFromStarted) async {
    var topWC = Get.find<TopWidgetController>();

    topWC.child.value = const RoundWidget();
    // round noti reverse
    await topWC.controller.reverse(
        from: 1 -
            durationFromStarted.inMicroseconds /
                MainContentAndFooter.animationDuration.inMicroseconds);

    topWC.child.value = PlayerChooseWordWidget(wordOptions: wordOptions, remainingTime: 15);

    await topWC.controller.forward();
  }

  void whenPlayerChooseWordForward(Duration durationFromStarted) async {
    var topWC = Get.find<TopWidgetController>();

    topWC.child.value = PlayerChooseWordWidget(
        wordOptions: wordOptions,
        remainingTime: (const Duration(seconds: 15) - durationFromStarted).inSeconds);
    topWC.controller.forward(
        from: durationFromStarted.inMicroseconds /
            MainContentAndFooter.animationDuration.inMicroseconds);
  }

  void whenPlayerChooseWordShown(Duration durationFromStarted) async {
    var topWC = Get.find<TopWidgetController>();

    topWC.child.value = PlayerChooseWordWidget(
        wordOptions: wordOptions,
        remainingTime: (const Duration(seconds: 15) - durationFromStarted).inSeconds);
  }

  @override
  Future<void> setup() async {
    // join from middle game
    var controller = Get.find<MainContentAndFooterController>();

    controller.child.value = Stack(
      children: [
        CanvasAndFooter(),

        // animate overlay
        const CanvasOverlay(),
        // animated settings

        TopWidget(child: Container())
        // const GameSettings()
      ],
    );

    await Get.find<CanvasOverlayController>().controller.forward();

    afterWaitForSetup();
  }

  @override
  Future<GameState> next(dynamic data) async {
    if (MePlayer.inst.id != playerId) {
      Game.inst.remainingTime.stop();
      await Get.find<TopWidgetController>().controller.reverse();
    }
    Game.inst.remainingTime.seconds.value = 0;
    await Get.find<CanvasOverlayController>().controller.reverse();

    return DrawState.afterChooseWord(startedAt: data['started_at'], playerId: playerId, word: data['word']);
  }
}

class RoundWidget extends StatelessWidget {
  const RoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('round_noti'.trParams({'round': Game.inst.currentRound.value.toString()}),
        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800));
  }
}

class PlayerChooseWordWidget extends StatelessWidget {
  PlayerChooseWordWidget({required this.wordOptions, required int remainingTime, super.key}) {
    // set timer
    Game.inst.remainingTime.start(remainingTime, () {
      if (MePlayer.inst.id == (Game.inst.state.value as StartRoundState).playerId) {
        // randomize word
        var rand = Random();
        var chosenWordIndex = rand.nextInt(wordOptions.length);
        Game.inst.chooseWord(wordOptions[chosenWordIndex]);
      }
      // for not guesser, clear top widget on socket io
    });
  }
  final List<dynamic> wordOptions;

  @override
  Widget build(BuildContext context) {
    var currentState = Game.inst.state.value;
    if (currentState is StartRoundState) {
      if (currentState.playerId == MePlayer.inst.id) {
        // CHECKED

        // me choose word
        List<WordItem> wordWidgets = [];
        for (var word in currentState.wordOptions) {
          wordWidgets.add(WordItem(word: word));
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('choose_a_word'.tr,
                style: const TextStyle(
                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: wordWidgets,
            )
          ],
        );
      }

      // CHECKED
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('player_choosing'.trParams({'playerName': currentState.playerName}),
              style:
                  const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
          Game.inst.playersByMap[currentState.playerId]!.avatar.doFitSize(height: 80, width: 80)
        ],
      );
    }
    throw Exception('PlayerChooseWordWidget: current state is not StartRound');
  }
}

class WordItem extends StatelessWidget {
  const WordItem({required this.word, super.key});
  final String word;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Game.inst.remainingTime.stop();
          Game.inst.chooseWord(word);
        },
        child: Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                border: Border.all(color: Colors.white, width: 4)),
            child: Text(word,
                style: const TextStyle(
                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800))));
  }
}
