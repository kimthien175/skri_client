import 'package:get/get.dart';
import 'package:skribbl_client/models/models.dart';
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

  static Duration get duration => const Duration(milliseconds: 300);

  @override
  void onInit() {
    super.onInit();

    controller = AnimationController(vsync: this, duration: duration);
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
    var gif = GifManager.inst.misc;
    return ClipRRect(
        child: SlideTransition(
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
                          AnimatedButtonOpacityDecorator(minOpacity: 0.6),
                          AnimatedButtonScaleDecorator()
                        ],
                        child: gif('thumb_up').builder.initWithShadow().fit(height: 50)),
                    AnimatedButton(
                        onTap: () {
                          controller.hide();
                          // TODO: SEND DISLIKE MSG
                        },
                        decorators: const [
                          AnimatedButtonOpacityDecorator(minOpacity: 0.6),
                          AnimatedButtonScaleDecorator()
                        ],
                        child: gif('thumb_down').builder.initWithShadow().fit(height: 50))
                  ],
                ))));
  }
}
