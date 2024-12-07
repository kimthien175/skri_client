library game_play_main_content_footer;

export 'overlay.dart';
export 'top_widget.dart';

import 'package:skribbl_client/models/game/game.dart';
import 'package:skribbl_client/pages/gameplay/gameplay.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/draw.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw_view/draw_view.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../models/game/state/draw.dart';

class MainContent extends StatelessWidget {
  MainContent({super.key}) {
    Get.put(CanvasOverlayController());
  }

  static Duration animationDuration = const Duration(milliseconds: 800);

  @override
  Widget build(BuildContext context) {
    return const Stack(children: [
      GameCanvas(),
    ]);
  }
}

class GameCanvas extends StatelessWidget {
  const GameCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var state = Game.inst.state.value;
      if (state is DrawState) {
        if (state.playerId == MePlayer.inst.id) return const DrawWidget();
      }
      return const DrawViewWidget();
    });
  }
}

class MainContentController extends GetxController {
  MainContentController() {
    // ignore: unnecessary_cast
    child = (canvas as Widget).obs;
  }

  late final Rx<Widget> child;
  final CanvasAndFooter canvas = CanvasAndFooter();

  void showSettings() {
    Get.find<CanvasAndFooterController>().child.value = const EmptyCanvasAndInvite();
    child.value = Stack(
      children: [
        canvas,

        // animate overlay
        const CanvasOverlay(),
        // animated settings

        TopWidget(child: GameSettings())
        // const GameSettings()
      ],
    );

    Get.find<CanvasOverlayController>().controller.forward().then(
      (value) {
        Get.find<TopWidgetController>().controller.forward();
      },
    );
  }

  clearCanvasAndHideTopWidget() async {
    Get.find<CanvasAndFooterController>().empty();
    await Get.find<TopWidgetController>().controller.reverse();
  }
}

class CanvasAndFooter extends StatelessWidget {
  CanvasAndFooter({Widget? child, super.key}) {
    Get.put(CanvasAndFooterController(child: child ?? CanvasAndFooterController.emptyCanvas));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Get.find<CanvasAndFooterController>().child.value);
  }
}

class CanvasAndFooterController extends GetxController {
  CanvasAndFooterController({required Widget child}) {
    this.child = child.obs;
  }
  late final Rx<Widget> child;
  void empty() {
    child.value = emptyCanvas;
  }

  static Widget emptyCanvas = Container(
    height: 600,
    width: 800,
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: GlobalStyles.borderRadius,
    ),
    alignment: Alignment.center,
  );
}

class EmptyCanvasAndInvite extends StatelessWidget {
  const EmptyCanvasAndInvite({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 800,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 600,
              width: 800,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: GlobalStyles.borderRadius,
              ),
              alignment: Alignment.center,
            ),
            GameplayStyles.layoutGap,
            if (Game.inst is PrivateGame) const InviteSection()
          ],
        ));
  }
}
