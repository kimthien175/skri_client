import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:cd_mobile/widgets/scaling_button.dart';
import 'package:flutter/material.dart';

class GameBar extends StatelessWidget {
  const GameBar({super.key});

  @override
  Widget build(BuildContext context) {
    var namedGifs = GifManager.inst.misc;
    return Container(
        constraints: const BoxConstraints.expand(height: 48),
        decoration: BoxDecoration(
            color: GlobalStyles.colorPlayerBGBase, borderRadius: GlobalStyles.borderRadius),
        child: Row(
          children: [
            Stack(alignment: Alignment.topLeft, clipBehavior: Clip.none, children: [
              Container(width: 200),
              const Positioned(top: -10, left: -8, child: GameClock())
            ]),
            const Flexible(child: Center(child: Text('waiting'))),
            Container(
                width: 300,
                alignment: Alignment.centerRight,
                child: ScalingButton(child: namedGifs('settings')
                    .builder
                    .initShadowedOrigin()
                    .doFitSize(height: 48, width: 48)))
          ],
        ));
  }
}

class GameClock extends StatelessWidget {
  const GameClock({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GifManager.inst.misc('clock').builder.init().doFitSize(width: 64, height: 64),
        const Text('0')
      ],
    );
  }
}
