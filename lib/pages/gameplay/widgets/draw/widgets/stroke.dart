import 'package:skribbl_client/models/gif_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../manager.dart';
import 'stroke_value_item.dart';

class StrokeValueSelector extends StatelessWidget {
  const StrokeValueSelector({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<StrokeValueItemController>(tag: 'stroke_value_selector');
    return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(3)),
        child: StrokeValueItem(
          isMain: true,
          controller: Get.find<StrokeValueItemController>(tag: 'stroke_value_selector'),
          onTap: () {
            Get.find<StrokeValueListController>().isOpened.value = true;
          },
          child: Obx(() {
            var size = 48 * controller.value.value / DrawManager.inst.strokeSizeList.last;
            return GifManager.inst
                .misc('stroke_size')
                .builder
                .initWithShadow(color: DrawManager.inst.currentColor, height: size, width: size);
          }
              // Text(controller.value.value.toStringAsFixed(2)),
              ),
        ));
  }
}

class StrokeValueListController extends GetxController {
  var isOpened = false.obs;
}

class StrokeValueList extends StatelessWidget {
  const StrokeValueList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<StrokeValueItem> items = [];
    var list = DrawManager.inst.strokeSizeList;
    for (int i = 0; i < list.length; i++) {
      var size = 48 * list[i] / list.last;
      items.add(StrokeValueItem(
          controller: StrokeValueItemController(list[i].obs),
          onTap: () {
            DrawManager.inst.currentStrokeSize = DrawManager.inst.strokeSizeList[i];
            Get.find<StrokeValueListController>().isOpened.value = false;
            Get.find<StrokeValueItemController>(tag: 'stroke_value_selector').value.value =
                DrawManager.inst.currentStrokeSize;
          },
          child: GifManager.inst
              .misc('stroke_size')
              .builder
              .initWithShadow(color: DrawManager.inst.currentColor, height: size, width: size)));
    }

    return TapRegion(
        onTapOutside: (event) {
          // except stroke selector
          if (Get.find<StrokeValueItemController>(tag: 'stroke_value_selector').isHovered.value) {
            return;
          }
          Get.find<StrokeValueListController>().isOpened.value = false;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                decoration: const BoxDecoration(
                    boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 7)]),
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: items))),
            CustomPaint(painter: StrokeListArrow(), size: const Size(12, 12))
          ],
        ));
  }
}

class StrokeListArrow extends CustomPainter {
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
