import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/draw_widget.dart';
import 'package:skribbl_client/pages/gameplay/widgets/game_bar/settings/settings.dart';

import '../manager.dart';

class RecentColor extends StatelessWidget with KeyMapWrapper {
  const RecentColor({super.key});

  // ignore: non_constant_identifier_names
  static final KeyMap KEYMAP =
      KeyMap(title: 'Swap', act: () => Get.find<RecentColorController>().switchColor(), order: 4);

  @override
  KeyMap get keyMap => KEYMAP;

  @override
  Widget get child => throw Exception('no need');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: keyMap.act,
        child: Obx(() {
          var keyMaps = SystemSettings.inst.keyMaps;
          final controller = Get.find<RecentColorController>();
          var currentColor = controller.last2Colors[1];
          return Stack(children: [
            ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                child: CustomPaint(
                    size: const Size(48, 48),
                    painter: RecentColorCustomPainter(currentColor, controller.last2Colors[0]))),
            Positioned(
                right: 2,
                top: -2,
                child: Text(keyMaps.keys.firstWhere((key) => keyMaps[key] == keyMap).keyLabel,
                    style: TextStyle(
                        color: currentColor == Colors.black ? Colors.white : null,
                        fontSize: 13,
                        fontVariations: [FontVariation.weight(900)])))
          ]);
        }));
  }
}

class RecentColorCustomPainter extends CustomPainter {
  RecentColorCustomPainter(this.current, this.last);
  final Color current;
  final Color last;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(last, BlendMode.src);
    final paint = Paint()
      ..color = current
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height / 4)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class RecentColorController extends GetxController {
  RecentColorController() {
    // currentColor and white
    var inst = DrawManager.inst;
    last2Colors = [inst.colorList[0], inst.currentColor].obs;
  }
  late RxList<Color> last2Colors;
  void switchColor() {
    last2Colors.value = [last2Colors[1], last2Colors[0]];
    DrawManager.inst.currentColor = last2Colors[1];
  }

  void addRecent() {
    if (last2Colors[1] == DrawManager.inst.currentColor) return;
    last2Colors.value = [last2Colors[1], DrawManager.inst.currentColor];
  }
}

class ColorSelector extends StatelessWidget {
  const ColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    var list = DrawManager.inst.colorList;
    for (int i = 0; i < list.length; i++) {
      items.add(InkWell(
          onTap: () => DrawManager.inst.currentColor = list[i],
          child: Container(height: 24, width: 24, color: list[i])));
    }
    return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(3)),
        child: SizedBox(
            width: 312,
            child: Wrap(
              children: items,
            )));
  }
}
