import 'package:cd_mobile/models/game/game.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:cd_mobile/widgets/animated_button/builder.dart';
import 'package:cd_mobile/widgets/animated_button/decorator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameBar extends StatelessWidget {
  const GameBar({super.key});
  @override
  Widget build(BuildContext context) {
    var namedGifs = GifManager.inst.misc;
    return Container(
        height: 48,
        width: 1312,
        // constraints:  BoxConstraints.expand(height:_height),
        decoration: BoxDecoration(
            color: GameplayStyles.colorPlayerBGBase,
            borderRadius: GlobalStyles.borderRadius),
        child: Row(
          children: [
            Stack(
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.none,
                children: [
                  const SizedBox(width: 200, height: 48),
                  const Positioned(top: -10, left: -8, child: GameClock()),
                  Positioned(
                      left: 60,
                      top: 13,
                      child: Obx(() => Text(
                          "gamebar_round_display".trParams({
                            "currentRound":
                                Game.inst.currentRound.value.toString(),
                            "rounds": Game.inst.rounds.value.toString()
                          }),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800))))
                ]),
            Flexible(
                child: Center(
                    child: Obx(() => Game.inst.state.value.middleStatusOnBar))),
            Container(
                width: 300,
                alignment: Alignment.centerRight,
                child: AnimatedButtonBuilder(
                        child: namedGifs('settings')
                            .builder
                            .initShadowedOrigin()
                            .doFitSize(height: 48, width: 48),
                        // opacityDecorator:
                        //     AnimatedButtonOpacityDecorator(minOpacity: 0.85),
                        onTap: () {
                          // TODO: SETTINGS BUTTON
                        })
                    .child)
          ],
        ));
  }
}

class GameClock extends StatelessWidget {
  const GameClock({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 64,
        width: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GifManager.inst
                .misc('clock')
                .builder
                .initShadowedOrigin()
                .doFitSize(width: 64, height: 64),
            Positioned(
                top: 20,
                child: Obx(() => Text(
                    Game.inst.remainingTime.seconds.value.toString(),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900))))
          ],
        ));
  }
}
