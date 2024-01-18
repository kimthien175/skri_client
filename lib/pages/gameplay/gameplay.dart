import 'package:cd_mobile/models/game_play/game.dart';
import 'package:cd_mobile/pages/gameplay/mobile/mobile.dart';
import 'package:cd_mobile/pages/gameplay/web/web.dart';
import 'package:cd_mobile/pages/gameplay/widgets/footer.dart';
import 'package:cd_mobile/pages/gameplay/widgets/invite_section.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content/main_content.dart';
import 'package:cd_mobile/pages/page_controller/responsive_page_controller.dart';
import 'package:cd_mobile/utils/socket_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameplayController extends ResponsivePageController {
  GameplayController() : super() {
    Get.put(MainContentController());
    Get.put(GameFooterController());
  }
  static Function()? setUp;
  @override
  void didChangeMetrics() {
    isWebLayout.value = webLayoutStatus;
    super.didChangeMetrics();
  }

  @override
  void onReady() {
    super.onReady();
    if (setUp != null) setUp!();
  }

  static setUpPrivateGame() {
    setUp = () {
      Get.find<MainContentController>().showSettings();
      Get.find<GameFooterController>().child.value = const InviteSection();
    };
  }
}

class GameplayPage extends StatelessWidget {
  GameplayPage({super.key});

  final GameplayController controller = Get.put(GameplayController());

  static onBack() {
    SocketIO.inst.socket.disconnect();
    Game.empty();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvoked: (didPop) {
          if (didPop) onBack();
        },
        child: Scaffold(
            body: Container(
                constraints: const BoxConstraints.expand(),
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        scale: 1.2,
                        repeat: ImageRepeat.repeat,
                        image: AssetImage('assets/background.png'))),
                child: SafeArea(
                    child:
                        Obx(() => controller.isWebLayout.value ? const Web() : const Mobile())))));
  }
}
