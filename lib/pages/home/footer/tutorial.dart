import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HowToPlayContent extends StatelessWidget {
  const HowToPlayContent({super.key});
  static final HowToPlayContentController controller = Get.put(HowToPlayContentController());
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            height: 232,
            child: Obx(() =>
                GifManager.inst.misc('tutorial_${controller.step.value}').widgetWithShadow())),
        SizedBox(
            height: 48,
            child: Obx(() => Text('section_how_to_play_step${controller.step.value}'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: PanelStyles.textColor, fontSize: 16, fontWeight: FontWeight.w500)))),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepButton(1),
            _StepButton(2),
            _StepButton(3),
            _StepButton(4),
            _StepButton(5),
          ],
        )
      ],
    );
  }
}

class HowToPlayContentController extends GetxController {
  var step = 1.obs;
}

class _StepButton extends StatelessWidget {
  const _StepButton(this.index);

  final int index;

  static final controller = Get.find<HowToPlayContentController>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 25,
        width: 25,
        child: IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              if (index != controller.step.value) {
                controller.step.value = index;
              }
            },
            icon: Obx(() => index == controller.step.value
                ? const Icon(Icons.circle, size: 18, color: Colors.white)
                : Icon(Icons.circle, size: 14, color: Colors.white.withOpacity(0.3)))));
  }
}
