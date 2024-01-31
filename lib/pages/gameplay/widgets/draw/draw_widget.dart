import 'package:cd_mobile/models/gif_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'manager.dart';
import 'mode.dart';
import 'widgets/color.dart';
import 'widgets/stroke.dart';
import 'widgets/stroke_value_item.dart';

class DrawWidget extends StatelessWidget {
  DrawWidget({super.key}) {
    DrawManager.init();
    Get.put(StrokeValueListController());
    Get.put(StrokeValueItemController(DrawTools.inst.currentStrokeSize.obs),
        tag: 'stroke_value_selector');
    Get.put(RecentColorController());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(children: [
          Column(children: [
            ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                child: Container(
                    height: DrawManager.height,
                    width: DrawManager.width,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: MouseRegion(
                        cursor: DrawTools.inst.currentMode.cursor,
                        child: GestureDetector(
                          onPanDown: (details) {
                            DrawManager.inst.onDown(details.localPosition);
                          },
                          onPanUpdate: (details) {
                            DrawManager.inst.onUpdate(details.localPosition);
                          },
                          onPanEnd: (details) {
                            DrawManager.inst.onEnd();
                          },
                          child: CustomPaint(
                              size: const Size(DrawManager.width, DrawManager.height),
                              painter: DrawStepCustomPainter(repaint: DrawManager.inst.repaint)),
                        )))),
            const SizedBox(height: 6),
            const SizedBox(
                width: 800,
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  RecentColor(),
                  SizedBox(width: 6),
                  ColorSelector(),
                  SizedBox(width: 6),
                  StrokeValueSelector(),
                  Spacer(),
                  BrushButton(),
                  SizedBox(width: 6),
                  FillButton(),
                  Spacer(),
                  UndoButton(),
                  SizedBox(width: 6),
                  ClearButton()
                ]))
          ]),
          if (Get.find<StrokeValueListController>().isOpened.value)
            Positioned(
                left: 360,
                top: 610 - 18 - DrawTools.inst.strokeSizeList.length * StrokeValueItem.size,
                child: const StrokeValueList())
        ]));
  }
}

class BrushButton extends StatelessWidget {
  const BrushButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          if (DrawTools.inst.currentMode is! BrushMode) {
            DrawTools.inst.currentMode = BrushMode();
          }
        },
        child: Obx(() => Container(
            decoration: BoxDecoration(
                color: DrawTools.inst.currentMode is BrushMode
                    ? const Color.fromRGBO(171, 102, 235, 1)
                    : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(3))),
            child: GifManager.inst
                .misc('pen')
                .builder
                .initShadowedOrigin()
                .doFitSize(height: 48, width: 48))));
  }
}

class FillButton extends StatelessWidget {
  const FillButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          if (DrawTools.inst.currentMode is! FillMode) {
            DrawTools.inst.currentMode = FillMode();
          }
        },
        child: Obx(() => Container(
            decoration: BoxDecoration(
                color: DrawTools.inst.currentMode is FillMode
                    ? const Color.fromRGBO(171, 102, 235, 1)
                    : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(3))),
            child: GifManager.inst
                .misc('fill')
                .builder
                .initShadowedOrigin()
                .doFitSize(height: 48, width: 48))));
  }
}

class UndoButton extends StatefulWidget {
  const UndoButton({super.key});

  @override
  State<UndoButton> createState() => _UndoButtonState();
}

class _UndoButtonState extends State<UndoButton> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (_) {
          setState(() {
            isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            isHovered = false;
          });
        },
        child: InkWell(
            onTap: DrawManager.inst.undo,
            child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(3))),
                child: Opacity(
                    opacity: isHovered ? 1 : 0.7,
                    child: GifManager.inst
                        .misc('undo')
                        .builder
                        .initShadowedOrigin()
                        .doFitSize(height: 48, width: 48)))));
  }
}

class ClearButton extends StatefulWidget {
  const ClearButton({super.key});

  @override
  State<ClearButton> createState() => _ClearButtonState();
}

class _ClearButtonState extends State<ClearButton> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (_) {
          setState(() {
            isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            isHovered = false;
          });
        },
        child: InkWell(
            onTap: DrawManager.inst.clear,
            child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(3))),
                child: Opacity(
                    opacity: isHovered ? 1 : 0.7,
                    child: GifManager.inst
                        .misc('clear')
                        .builder
                        .initShadowedOrigin()
                        .doFitSize(height: 48, width: 48)))));
  }
}
