library;

export 'layouts/web.dart';
export 'layouts/mobile.dart';
export 'widgets/widgets.dart';

import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/utils/sound.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/widgets/widgets.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameplayPage extends StatefulWidget {
  const GameplayPage({super.key});

  static bool isWebLayout(BuildContext context) {
    if (context.width >= context.height) {
      // web
      OverlayController.scale = (_) => 1.0;
      return true;
    }
    OverlayController.scale = (ct) => GameBarMobile.getHeight(ct) / GameBar.webHeight;
    return false;
  }

  @override
  State<GameplayPage> createState() => _GameplayPageState();
}

class _GameplayPageState extends State<GameplayPage> {
  @override
  void initState() {
    super.initState();

    Get.put(PlayersListController());
    Get.put(GameClockController());
    Get.put(GameChatController());

    Get.put(LikeAndDislikeController());
    DrawManager.init();

    Get.put(TopWidgetController());
    Get.put(HintController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Game.inst.runState();

      Sound.inst.play(Sound.inst.join);

      // scroll to bottom
      Get.find<GameChatController>().scrollToBottom();
    });
  }

  @override
  void dispose() {
    Game.inst = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Background(
      child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            Game.inst.confirmLeave();
          },
          child: GameplayPage.isWebLayout(context) ? const GameplayWeb() : const GameplayMobile()));
}
