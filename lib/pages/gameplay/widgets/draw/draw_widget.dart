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
            const SizedBox(height: 10),
            SizedBox(
                width: 800,
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const RecentColor(),
                  const ColorSelector(),
                  const StrokeValueSelector(),
                  ElevatedButton(
                      child: Text('Brush'),
                      onPressed: () {
                        print('Brush');
                        if (DrawTools.inst.currentMode is! BrushMode) {
                          DrawTools.inst.currentMode = BrushMode();
                        }
                      }),
                  ElevatedButton(
                    child: Text('Fill'),
                    onPressed: () {
                      print('Fill');
                      if (DrawTools.inst.currentMode is! FillMode) {
                        DrawTools.inst.currentMode = FillMode();
                      }
                    },
                  ),
                  ElevatedButton(child: Text('Undo'), onPressed: DrawManager.inst.undo),
                  ElevatedButton(
                    child: Text('Clear'),
                    onPressed: DrawManager.inst.clear,
                  )
                ]))
          ]),
          if (Get.find<StrokeValueListController>().isOpened.value)
            Positioned(
                left: 360,
                top: 610 - 12 - DrawTools.inst.strokeSizeList.length * StrokeValueItem.size,
                child: const StrokeValueList())
        ]));
  }
}
