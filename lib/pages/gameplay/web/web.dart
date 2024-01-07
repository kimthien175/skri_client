import 'package:cd_mobile/pages/gameplay/widgets/game_bar.dart';
import 'package:cd_mobile/pages/gameplay/widgets/game_canvas.dart';
import 'package:cd_mobile/pages/gameplay/widgets/game_chat.dart';
import 'package:cd_mobile/pages/gameplay/widgets/game_players.dart';
import 'package:cd_mobile/pages/gameplay/widgets/game_toolbar.dart';
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
                      // TODO: disconnect and get to homepage
                      Get.toNamed('/');
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
            Column(children: [const GameCanvas(), GameplayStyles.layoutGap, const GameToolbar()]),
            GameplayStyles.layoutGap,
            const GameChat()
          ],
        )
      ],
    );
    // return GridView.count(
    //   crossAxisCount: 3, // 3 cells on x direction
    //   mainAxisSpacing: 10,
    //   crossAxisSpacing: 10,
    //   children: [
    //     GameBar(),
    //     GamePlayers(),
    //     GameCanvas(),
    //     GameChat(),
    //   ],
    // );
  }
}
