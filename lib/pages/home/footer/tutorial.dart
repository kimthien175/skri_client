import 'dart:async';

import 'package:skribbl_client/models/gif_manager.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HowToPlayContent extends GetView<HowToPlayContentController> {
  const HowToPlayContent({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
            child: Obx(() =>
                GifManager.inst.misc('tutorial_${controller.step}').builder.initWithShadow())),
        SizedBox(
            height: 48,
            child: Obx(() => Text('section_how_to_play_step${controller.step}'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: PanelStyles.textColor, fontSize: 16, fontWeight: FontWeight.w500)))),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
  HowToPlayContentController() {
    startTimer();
  }
  var _step = 1.obs;
  int get step => _step.value;

  late Timer timer;

  void jumpToStep(int step) {
    _step.value = step;
    timer.cancel();
    startTimer();
  }

  void switchToNextStep(Timer timer) {
    if (step == 5) {
      _step.value = 1;
    } else {
      _step++;
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 4), switchToNextStep);
  }

  @override
  void onClose() {
    timer.cancel();
  }
}

class _StepButton extends GetView<HowToPlayContentController> {
  const _StepButton(this.index);

  final int index;

  @override
  Widget build(BuildContext context) {
    var isHover = false;
    return Container(
        alignment: Alignment.center,
        height: 25,
        width: 25,
        child: GestureDetector(
            onTap: () {
              if (index != controller.step) {
                controller.jumpToStep(index);
              }
            },
            child: StatefulBuilder(
                builder: (ct, setState) => MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) {
                      setState(() {
                        isHover = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        isHover = false;
                      });
                    },
                    child: Obx(() => AnimatedContainer(
                        duration: const Duration(milliseconds: 80),
                        decoration: BoxDecoration(
                            color: (isHover || index == controller.step)
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle),
                        width: index == controller.step ? 14.25 : 11,
                        height: index == controller.step ? 14.25 : 11))))));
  }
}
