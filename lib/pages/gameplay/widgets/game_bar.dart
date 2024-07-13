import 'package:skribbl_client/models/gif_manager.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/styles.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';

// TODO: SYNC TO GAME
class GameBar extends StatelessWidget {
  const GameBar({super.key});
  static const double height = 48.0;
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.centerLeft, clipBehavior: Clip.none, children: [
      Container(
          constraints: const BoxConstraints.expand(height: height),
          decoration: BoxDecoration(
              color: GameplayStyles.colorPlayerBGBase, borderRadius: GlobalStyles.borderRadius),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const SizedBox(width: PlayerCard.width),
            Text(
              'WAITING'.tr,
              style: const TextStyle(
                  fontFamily: 'Inconsolata', fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Container(
                width: GameChat.width,
                alignment: Alignment.centerRight,
                child: AnimatedButton(
                    decorators: [
                      AnimatedButtonOpacityDecorator(minOpacity: 0.9),
                      AnimatedButtonScaleDecorator(minSize: 1 / 1.1)
                    ],
                    child: GifManager.inst
                        .misc('settings')
                        .builder
                        .initShadowedOrigin(filterQuality: FilterQuality.none)
                        .doFitSize(height: 42 * 1.1, width: 42 * 1.1)))
          ])),
      const Positioned(top: -10, left: -8, child: GameClock()),
      Positioned(
          left: 60,
          top: 13,
          child:
              //Obx(() =>
              Text(
                  "gamebar_round_display".trParams({
                    "currentRound": '1', //Game.inst.currentRound.value.toString(),
                    "rounds": '3' //Game.inst.rounds.value.toString()
                  }),
                  style: const TextStyle(
                      fontFamily: 'Nunito-var',
                      fontSize: 19.6,
                      fontVariations: [FontVariation.weight(720)])))
      //)
    ]);

    // Container(
    //     width: 300,
    //     alignment: Alignment.centerRight,
    //     child: AnimatedButtonBuilder(
    //             child: namedGifs('settings')
    //                 .builder
    //                 .initShadowedOrigin()
    //                 .doFitSize(height: 48, width: 48),
    //             decorators: [AnimatedButtonOpacityDecorator(minOpacity: 0.85)],
    //             onTap: () {

    //             })
    //         .child)
  }
}

// TODO: ADD EFFECT WHEN ALMOST RUN OUT OF TIME
class GameClock extends StatelessWidget {
  const GameClock({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GifManager.inst.misc('clock').builder.initShadowedOrigin().doFitSize(width: 64, height: 64),
        const Positioned(
            top: 20,
            child:
                //Obx(() =>
                Text('0', //Game.inst.remainingTime.seconds.value.toString(),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)))
        //)
      ],
    );
  }
}
