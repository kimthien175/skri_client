import 'package:cd_mobile/pages/gameplay/web/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameplayPage extends StatelessWidget {
  GameplayPage({super.key});

  final GameplayController controller = Get.put(GameplayController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
                image: DecorationImage(
                    scale: 1.2,
                    repeat: ImageRepeat.repeat,
                    image: AssetImage('assets/background.png'))),
            child: const SafeArea(child: Web())));
  }
}

class GameplayController extends GetxController {}
