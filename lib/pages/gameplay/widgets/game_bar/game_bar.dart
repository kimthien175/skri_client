library game_bar;

export 'clock.dart';

import 'package:skribbl_client/models/game/game.dart';
import 'package:skribbl_client/pages/gameplay/widgets/game_bar/settings/settings.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/styles.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// TODO: SYNC TO GAME
class GameBar extends StatelessWidget {
  const GameBar({super.key});
  static const double height = 48.0;
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.centerLeft, clipBehavior: Clip.none, children: [
      Container(
          constraints: const BoxConstraints.expand(height: height),
          decoration: const BoxDecoration(
              color: GameplayStyles.colorPlayerBGBase, borderRadius: GlobalStyles.borderRadius),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const SizedBox(width: PlayerCard.width),
            Text(
              'WAITING'.tr,
              style: const TextStyle(
                  fontFamily: 'Inconsolata',
                  fontVariations: [FontVariation.weight(700)],
                  fontSize: 16),
            ),
            const SizedBox(width: GameChat.width)
          ])),
      const Positioned(top: -10, left: -8, child: GameClock()),
      Positioned(
          left: 60,
          top: 13,
          child: Obx(() => Text(
              "gamebar_round_display".trParams({
                "currentRound": '1', //Game.inst.currentRound.value.toString(),
                "rounds": Game.inst.settings['rounds'].toString()
              }),
              style: const TextStyle(
                  fontFamily: 'Nunito-var',
                  fontSize: 19.6,
                  fontVariations: [FontVariation.weight(720)])))),
      const Positioned(right: 3, child: SettingsButton())
    ]);
  }
}
