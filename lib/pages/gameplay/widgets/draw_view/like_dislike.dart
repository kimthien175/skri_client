import 'package:get/get.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';
import 'package:skribbl_client/widgets/overlay/position.dart';

class LikeAndDislikeOverlayController extends PositionedOverlayController<OverlayWidgetPosition>
    with GetSingleTickerProviderStateMixin {
  LikeAndDislikeOverlayController({required super.anchorKey})
      : super(
            childBuilder: () => const _LikeAndDislikeButtons(),
            position: const OverlayWidgetPosition.innerTopRight());

  late final AnimationController controller;
  late final Animation<Offset> offsetAnim;
  late final Animation<double> opacAnim;

  @override
  void onInit() {
    super.onInit();

    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    offsetAnim = controller.drive(Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero));
    opacAnim = controller.drive(Tween(begin: 0.5, end: 1.0));
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }

  @override
  Future<bool> show() async {
    if (await super.show()) {
      await controller.forward();
      return true;
    }
    return false;
  }
}

class _LikeAndDislikeButtons extends StatelessWidget {
  const _LikeAndDislikeButtons();

  @override
  Widget build(BuildContext context) {
    var controller = OverlayWidget.of<LikeAndDislikeOverlayController>(context);
    return SlideTransition(
        position: controller.offsetAnim,
        child: FadeTransition(
            opacity: controller.opacAnim,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedButton(
                    onTap: () {
                      controller.hide();
                      // TODO: SEND LIKE MSG
                    },
                    decorators: const [
                      // TODO: ADD SCALE DECORATOR
                    ],
                    child: Image.asset('assets/gif/thumbsup.gif')),
                AnimatedButton(
                    onTap: () {
                      controller.hide();
                      // TODO: SEND DISLIKE MSG
                    },
                    decorators: const [
                      // TODO: ADD SCALE DECORATOR
                    ],
                    child: Image.asset('assets/gif/thumbsdown.gif'))
              ],
            )));
  }
}
