library;

export 'layouts/web.dart';
export 'layouts/mobile.dart';
export 'widgets/widgets.dart';

import 'package:skribbl_client/models/game/state/draw/draw.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/pages/pages.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/page_background.dart';

import 'widgets/draw/manager.dart';

class GameplayPage extends StatefulWidget {
  const GameplayPage({super.key});

  static bool isWebLayout(BuildContext context) => context.width >= context.height;

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

      // scroll to bottom
      Get.find<GameChatController>().scrollToBottom();
    });
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
