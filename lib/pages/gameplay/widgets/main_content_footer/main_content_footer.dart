import 'package:cd_mobile/models/game/game.dart';
import 'package:cd_mobile/models/game/private_game.dart';
import 'package:cd_mobile/pages/gameplay/widgets/game_settings.dart';
import 'package:cd_mobile/pages/gameplay/widgets/invite_section.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content_footer/overlay.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content_footer/top_widget.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainContentAndFooter extends StatelessWidget {
  MainContentAndFooter({super.key}) {
    Get.put(CanvasOverlayController());
  }

  static Duration animationDuration = const Duration(milliseconds: 800);

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<MainContentAndFooterController>();
    return Obx(() => controller.child.value);
  }
}

class MainContentAndFooterController extends GetxController {
  MainContentAndFooterController() {
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
    decoration: BoxDecoration(
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
              decoration: BoxDecoration(
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
