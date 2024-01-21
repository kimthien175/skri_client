import 'package:cd_mobile/models/game_play/game.dart';
import 'package:cd_mobile/pages/gameplay/gameplay.dart';
import 'package:cd_mobile/pages/gameplay/widgets/footer.dart';
import 'package:cd_mobile/pages/gameplay/widgets/game_bar.dart';
import 'package:cd_mobile/pages/gameplay/widgets/game_chat.dart';
import 'package:cd_mobile/pages/gameplay/widgets/game_players.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content/main_content.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:cd_mobile/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Web extends StatelessWidget {
  const Web({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),
        SizedBox(
            width: 1312,
            child: Align(
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                    width: 320,
                    child: FittedBox(child: Logo(() {
                                            Game.inst.leave();
                      //Get.back();

                    }))))),
        GameplayStyles.layoutGap,
        const GameBar(),
        GameplayStyles.layoutGap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const GamePlayers(),
            GameplayStyles.layoutGap,
            Column(children: [MainContent(), GameplayStyles.layoutGap, const GameFooter()]),
            GameplayStyles.layoutGap,
            const GameChat()
          ],
        )
      ],
    );
  }
}
