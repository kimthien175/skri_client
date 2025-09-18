import 'package:skribbl_client/models/gif_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';

import '../manager.dart';
import 'stroke_value_item.dart';

class StrokeValueSelector extends StatelessWidget {
  const StrokeValueSelector({super.key});

  static StrokeValueListController get listController =>
      OverlayController.cache(tag: 'stroke_list', builder: () => StrokeValueListController());

  @override
  Widget build(BuildContext context) {
    return listController.attach(ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(3)),
        child: StrokeValueItem(
            isMain: true,
            controller: Get.find<StrokeValueItemController>(tag: 'stroke_value_selector'),
            onTap: listController.show,
            child: Obx(() {
              var size = 48 *
                  Get.find<StrokeValueItemController>(tag: 'stroke_value_selector').value.value /
                  DrawManager.inst.strokeSizeList.last;
              return GifManager.inst
                  .misc('stroke_size')
                  .builder
                  .initWithShadow(color: DrawManager.inst.currentColor)
                  .fit(height: size, width: size);
            }))));
  }
}

class StrokeValueListController extends TooltipController {
  StrokeValueListController()
      : super(tooltip: const StrokeValueList(), position: const TooltipPosition.centerTop());
}

class StrokeValueList extends StatelessWidget {
  const StrokeValueList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<StrokeValueItem> items = [];
    var list = DrawManager.inst.strokeSizeList;
    var listController = StrokeValueSelector.listController;
    for (int i = 0; i < list.length; i++) {
      var size = 48 * list[i] / list.last;
      items.add(StrokeValueItem(
          controller: StrokeValueItemController(list[i].obs),
          onTap: () {
            DrawManager.inst.currentStrokeSize = DrawManager.inst.strokeSizeList[i];
            listController.hide();
            Get.find<StrokeValueItemController>(tag: 'stroke_value_selector').value.value =
                DrawManager.inst.currentStrokeSize;
          },
          child: GifManager.inst
              .misc('stroke_size')
              .builder
              .initWithShadow(color: DrawManager.inst.currentColor)
              .fit(height: size, width: size)));
    }

    return TapRegion(
        onTapOutside: (event) {
          // except stroke selector
          if (Get.find<StrokeValueItemController>(tag: 'stroke_value_selector').isHovered.value) {
            return;
          }
          listController.hide();
        },
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Material(
              child: Container(
                  decoration: const BoxDecoration(
                      boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 7)]),
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                      child: Column(mainAxisSize: MainAxisSize.min, children: items)))),
          CustomPaint(painter: _StrokeListArrow(), size: const Size(12, 12))
        ]));
  }
}

class _StrokeListArrow extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
