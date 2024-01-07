import 'package:cd_mobile/pages/gameplay/widgets/game_bar.dart';
import 'package:cd_mobile/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Web extends StatelessWidget {
  const Web({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            width: 320,
            child: FittedBox(child: Logo(() {
              // TODO: disconnect and get to homepage
              Get.toNamed('/');
            }))),

       const GameBar(),
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
