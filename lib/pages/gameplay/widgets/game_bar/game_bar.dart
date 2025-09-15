library;

export 'clock.dart';

import 'package:skribbl_client/models/game/game.dart';
import 'package:skribbl_client/pages/gameplay/widgets/game_bar/settings/settings.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/styles.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameBar extends StatelessWidget {
  const GameBar({super.key});

  static const double webHeight = 48.0;
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.centerLeft, clipBehavior: Clip.none, children: [
      Container(
          constraints: const BoxConstraints.expand(height: webHeight),
          decoration: const BoxDecoration(
              color: GameplayStyles.colorPlayerBGBase, borderRadius: GlobalStyles.borderRadius),
          child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SizedBox(width: PlayerCard.width),
            _Status(),
            SizedBox(width: GameChat.width)
          ])),
      const Positioned(top: -10, left: -8, child: GameClock()),
      const Positioned(left: 60, top: 13, child: _Round()),
      const Positioned(right: 3, child: SettingsButton())
    ]);
  }
}

class GameBarMobile extends GameBar {
  const GameBarMobile({super.key});

  static double getHeight(BuildContext context) => GameplayMobile.scaleRatio * context.width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: getHeight(context),
        child: FittedBox(
            child: Stack(alignment: Alignment.centerLeft, clipBehavior: Clip.none, children: [
          Container(
            alignment: Alignment.center,
            height: GameBar.webHeight,
            width: GameBar.webHeight / GameplayMobile.scaleRatio,
            decoration: const BoxDecoration(
                color: GameplayStyles.colorPlayerBGBase, borderRadius: GlobalStyles.borderRadius),
            child: const _Status(),
          ),
          const Positioned.fill(
              left: 5,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(child: Column(children: [GameClock(), _Round()])))),
          const Positioned(right: 3, child: SettingsButton())
        ])));
  }
}

class _Round extends StatelessWidget {
  const _Round();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Text(
        "gamebar_round_display".trParams({
          "currentRound": Game.inst.currentRound.value.toString(),
          "rounds": Game.inst.settings['rounds'].toString()
        }),
        style: const TextStyle(
            fontFamily: 'Nunito-var',
            fontSize: 19.6,
            fontVariations: [FontVariation.weight(720)])));
  }
}

class _Status extends StatelessWidget {
  const _Status();

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
        style: const TextStyle(
            fontFamily: 'Inconsolata', fontVariations: [FontVariation.weight(700)], fontSize: 16),
        child: Obx(() => Game.inst.state.value.status));
  }
}
