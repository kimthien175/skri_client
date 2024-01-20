import 'package:cd_mobile/models/game_play/game.dart';
import 'package:cd_mobile/models/game_play/player.dart';
import 'package:cd_mobile/pages/gameplay/mobile/mobile.dart';
import 'package:cd_mobile/pages/gameplay/web/web.dart';
import 'package:cd_mobile/pages/gameplay/widgets/footer.dart';
import 'package:cd_mobile/pages/gameplay/widgets/invite_section.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content/main_content.dart';
import 'package:cd_mobile/pages/page_controller/responsive_page_controller.dart';
import 'package:cd_mobile/utils/socket_io.dart';
import 'package:cd_mobile/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameplayBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameplayController>(() => GameplayController());
  }
}

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

  static setUpOwnedPrivateGame() {
    setUp = () {
      Get.find<MainContentController>().showSettings();
      Get.find<GameFooterController>().child.value = const InviteSection();
    };
  }

  var isLoading = false.obs;
}

class GameplayPage extends StatelessWidget {
  const GameplayPage({super.key});

  // final GameplayController controller = Get.put(GameplayController());

  static onBack() {
    SocketIO.inst.socket.disconnect();
    Game.empty();
    // reset meplayer as well
    var me = MePlayer.inst;
    me.isOwner = false;
    me.points = 0;
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<GameplayController>();
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
                child: Obx(() {
                  var content =
                      SafeArea(child: controller.isWebLayout.value ? const Web() : const Mobile());
                  return controller.isLoading.value
                      ? Stack(
                        alignment: Alignment.center,
                          children: [content, const LoadingOverlay()],
                        )
                      : content;
                }))));
  }
}
