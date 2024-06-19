import 'package:cd_mobile/utils/overlay.dart';
import 'package:cd_mobile/widgets/animated_button/builder.dart';
import 'package:cd_mobile/widgets/animated_button/decorator.dart';
import 'package:cd_mobile/widgets/animated_button/decorators/tooltip/controller.dart';
import 'package:cd_mobile/widgets/animated_button/decorators/tooltip/position.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedButtonTooltipDecorator extends AnimatedButtonDecorator {
  AnimatedButtonTooltipDecorator(
      {required this.tooltip, AnimatedButtonTooltipPosition? position, double Function()? scale}) {
    _scale = scale ?? () => 1.0;
    this.position = position ?? TooltipPositionTop();
    controller = Get.put(ScaleTooltipController(), tag: this.position.hashCode.toString());
  }

  final String tooltip;
  late final AnimatedButtonTooltipPosition position;
  late final ScaleTooltipController controller;
  late final double Function() _scale;

  OverlayEntry? overlayEntry;

  void removeOverlayEntry() {
    if (overlayEntry == null) return;
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  static Color tooltipBackgroundColor = const Color.fromRGBO(69, 113, 255, 1.0);

  @override
  void decorate(AnimatedButtonBuilder builder) {
    builder.onEnterCallbacks.add((e) {
      if (overlayEntry != null) return;

      //#region add tooltip

      //#region create overlay

      overlayEntry = OverlayEntry(
          builder: (BuildContext context) => position.build(
                originalBox: builder.buttonKey.currentContext!.findRenderObject() as RenderBox,
                scale: _scale(),
                child: DefaultTextStyle(
                  style: const TextStyle(
                      color: Color.fromRGBO(240, 240, 240, 1),
                      fontWeight: FontWeight.w700,
                      fontSize: 13.0,
                      fontFamily: 'Nunito'),
                  child: Text(
                    tooltip,
                  ),
                ),
              ));

      //#endregion

      addOverlay(overlayEntry!);
      //#endregion

      // show tooltip
      controller.animController.forward();
    });

    builder.onExitCallbacks.add((e) {
      controller.animController.reverse().then((_) {
        removeOverlayEntry();
      });
    });
  }

  @override
  void onClose() {
    print('tool tip decorator clear');
    removeOverlayEntry();
    controller.dispose();
  }
}
