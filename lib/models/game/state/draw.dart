import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skribbl_client/models/models.dart';

import 'package:get/get.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/manager.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/utils.dart';

class DrawState extends GameState {
  DrawState({required super.data}) {}

  String get playerId => data['player_id'];
  String get word => data['word'];

  bool get isSpectator => playerId != MePlayer.inst.id;

  @override
  Widget get topWidget => const SizedBox();

  @override
  Widget get status {
    if (!isSpectator) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Text('DRAW_THIS'.tr),
        Text(word,
            style: const TextStyle(fontVariations: [FontVariation.weight(900)], fontSize: 25.2))
      ]);
    }

    switch (Game.inst.settings['word_mode']) {
      case _NormalWordModeStatus.value:
        return _NormalWordModeStatus();
      case _HiddenWordModeStatus.value:
        return _HiddenWordModeStatus();
      default:
        return _CombinationWordModeStatus();
    }
  }

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
  //       return ;
  //     }
  //   }
  //   return
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
  Future<void> onStart(Duration sinceStartDate) async {
    Get.find<GameClockController>()
        .start(Duration(seconds: Game.inst.settings['draw_time']) - sinceStartDate);

    if (isSpectator) {
      DrawViewManager.inst.clear(null);

      // LIKE_DISLIKE BUTTONS
      Get.find<DrawViewController>().buttonsController.show();
    } else {
      DrawManager.inst.reset();
    }
  }

  @override
  Future<Duration> onEnd(Duration sinceEndDate) async {
    var topWidget = Get.find<TopWidgetController>();
    // word reveal
    if (sinceEndDate < TopWidgetController.backgroundDuration) {
      await topWidget.backgroundController
          .forward(from: sinceEndDate / TopWidgetController.backgroundDuration);
      sinceEndDate = Duration.zero;
    } else {
      topWidget.backgroundController.value = 1;
      sinceEndDate -= TopWidgetController.backgroundDuration;
    }

    if (sinceEndDate < TopWidgetController.contentDuration) {
      await topWidget.contentController
          .forward(from: sinceEndDate / TopWidgetController.contentDuration);
      return Duration.zero;
    } else {
      topWidget.contentController.value = 1;
      return sinceEndDate - TopWidgetController.contentDuration;
    }
  }
}

class _NormalWordModeStatus extends GetView<_NormalWordModeStatusController> {
  const _NormalWordModeStatus();
  static const String value = 'Normal';

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text('GUESS_THIS'.tr), Obx(() => Text(controller.hint.value))]);
  }
}

class _NormalWordModeStatusController extends GetxController {
  late final Timer timer;
  late RxString hint;

  @override
  void onInit() {
    super.onInit();
    var state = Game.inst.state.value as DrawState;

    hint = state.word.replaceAll(RegExp(r'\S'), '_').obs;

    int drawTime = Game.inst.settings['draw_time'] as int;

    timer = Timer.periodic(
        Duration(milliseconds: (drawTime * 1000 / state.word.replaceAll(' ', '').length).toInt()),
        revealARandomCharacter);
  }

  void revealARandomCharacter(Timer timer) {
    var word = (Game.inst.state.value as DrawState).word;

    var rand = Random();
    late int charIndex;
    do {
      charIndex = rand.nextInt(hint.value.length);
    } while (hint.value[charIndex] != '_');

    hint.value = hint.value.replaceRange(charIndex, charIndex + 1, word[charIndex]);

    if (hint.value == word) {
      timer.cancel();
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

class _HiddenWordModeStatus extends StatelessWidget {
  const _HiddenWordModeStatus();

  static const String value = 'Hidden';
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [Text('WORD_HIDDEN'.tr), Text('???')]);
  }
}

class _CombinationWordModeStatus extends StatefulWidget {
  const _CombinationWordModeStatus();

  @override
  State<_CombinationWordModeStatus> createState() => __CombinationWordModeStatusState();
}

class __CombinationWordModeStatusState extends State<_CombinationWordModeStatus> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [Text('GUESS_THIS'.tr), Text('______ ____')],
    );
  }
}
