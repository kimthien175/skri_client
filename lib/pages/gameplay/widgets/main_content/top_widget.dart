import 'package:skribbl_client/models/game/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/styles.dart';

class TopWidget extends StatelessWidget {
  const TopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<TopWidgetController>();
    return IgnorePointer(
        child: Stack(children: [
      FadeTransition(
          opacity: controller.backgroundOpactityAnimation,
          child: Container(
            height: 600,
            width: 800,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(3, 8, 29, 0.8),
              borderRadius: GlobalStyles.borderRadius,
            ),
          )),
      ClipRect(
          child: SlideTransition(
              position: controller.offsetAnimation,
              child: SizedBox(
                  height: 600,
                  width: 800,
                  child: Center(child: Obx(() => Game.inst.state.value.topWidget)))))
    ]));
  }
}

class TopWidgetController extends GetxController with GetTickerProviderStateMixin {
  late final AnimationController contentController;
  late final AnimationController backgroundController;
  late final Animation<Offset> offsetAnimation;
  late final Animation<double> backgroundOpactityAnimation;

  static Duration get contentDuration => const Duration(milliseconds: 800);
  static Duration get backgroundDuration => const Duration(milliseconds: 800);

  @override
  void onInit() {
    super.onInit();
    contentController = AnimationController(
      duration: TopWidgetController.contentDuration,
      vsync: this,
    );

    backgroundController = AnimationController(
      duration: TopWidgetController.backgroundDuration,
      vsync: this,
    );

    offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: contentController, curve: Curves.easeOutBack));

    backgroundOpactityAnimation = Tween(begin: 0.0, end: 1.0).animate(backgroundController);
  }

  @override
  onClose() {
    contentController.dispose();
    backgroundController.dispose();
    super.onClose();
  }
}
