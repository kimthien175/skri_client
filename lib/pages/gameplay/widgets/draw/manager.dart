// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:skribbl_client/pages/gameplay/gameplay.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/widgets/stroke_value_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils.dart';
import 'mode.dart';
import 'step/clear.dart';
import 'step/plain.dart';
import 'step/step.dart';
import 'widgets/color.dart';
import 'widgets/stroke.dart';

class DrawManager {
  static DrawManager? _inst;
  static DrawManager get inst => _inst!;
  static void init() {
    DrawManager._inst = DrawManager._internal();
    Get.put(StrokeValueListController());
    Get.put(StrokeValueItemController(DrawManager.inst.currentStrokeSize.obs),
        tag: 'stroke_value_selector');
    Get.put(RecentColorController());
  }

  // singleton
  DrawManager._internal() {
    _currentColor = colorList[13];
    _currentStrokeSize = strokeSizeList[1];
  }

  final List<Color> colorList = const [
    Color.fromRGBO(255, 255, 255, 1),
    Color.fromRGBO(193, 193, 193, 1),
    Color.fromRGBO(239, 19, 11, 1),
    Color.fromRGBO(255, 113, 0, 1),
    Color.fromRGBO(255, 228, 0, 1),
    Color.fromRGBO(0, 204, 0, 1),
    Color.fromRGBO(0, 255, 145, 1),
    Color.fromRGBO(0, 178, 255, 1),
    Color.fromRGBO(35, 31, 211, 1),
    Color.fromRGBO(163, 0, 186, 1),
    Color.fromRGBO(223, 105, 167, 1),
    Color.fromRGBO(255, 172, 142, 1),
    Color.fromRGBO(160, 82, 45, 1),
    //
    Color.fromRGBO(0, 0, 0, 1),
    Color.fromRGBO(80, 80, 80, 1),
    Color.fromRGBO(116, 11, 7, 1),
    Color.fromRGBO(194, 56, 0, 1),
    Color.fromRGBO(232, 162, 0, 1),
    Color.fromRGBO(0, 70, 25, 1),
    Color.fromRGBO(0, 120, 93, 1),
    Color.fromRGBO(0, 86, 158, 1),
    Color.fromRGBO(14, 8, 101, 1),
    Color.fromRGBO(85, 0, 105, 1),
    Color.fromRGBO(135, 53, 84, 1),
    Color.fromRGBO(204, 119, 77, 1),
    Color.fromRGBO(99, 48, 13, 1),
  ];

  final List<double> strokeSizeList = [
    0.2 * 20,
    (1 / 3) * 20,
    (5 / 9) * 20,
    (37 / 45) * 20,
    1 * 20
  ];

  late Color _currentColor;
  Color get currentColor => _currentColor;
  set currentColor(Color value) {
    _currentColor = value;

    currentStep.changeColor();

    Get.find<RecentColorController>().addRecent();

    var mainStrokeItemController =
        Get.find<StrokeValueItemController>(tag: 'stroke_value_selector');
    mainStrokeItemController.value.refresh();
    mainStrokeItemController.isHovered.refresh();
  }

  late double _currentStrokeSize;
  double get currentStrokeSize => _currentStrokeSize;
  set currentStrokeSize(double value) {
    _currentStrokeSize = value;

    currentStep.changeStrokeSize();
  }

  final Rx<DrawMode> _currentMode = DrawMode.brush().obs;
  DrawMode get currentMode => _currentMode.value;
  set currentMode(DrawMode mode) {
    _currentMode.value = mode;
    currentStep = _newCurrentStep;
  }

  late GestureDrawStep currentStep = _newCurrentStep;
  GestureDrawStep get _newCurrentStep => _currentMode.value.stepFactory();

  void onEnd() {
    if (!currentStep.onEnd) return;

    // move step from current to past
    pushTail(currentStep);

    currentStep = _newCurrentStep;
  }

  final ChangeNotifier _currentStepRepaint = ChangeNotifier();

  /// Only BrushStep can access this
  ChangeNotifier get currentStepRepaint => _currentStepRepaint;

  // add ClearStep to past
  void clear() {
    // if past is empty, return
    if (_tail == null ||
        (_tail is PlainDrawStep && (_tail as PlainDrawStep).color == Colors.white)) {
      return;
    }

    pushTail(ClearStep());
  }

  static const double width = MainContent.width;
  static const double height = MainContent.height;

  // printFromTailToHead() {
  //   print('[START PRINT]');
  //   DrawStep? node = _tail;
  //   while (node != null) {
  //     print(node);
  //     node = node.prev;
  //   }
  // }

  //#region Linked List

  /// push new tail, set id for the tail
  void pushTail(DrawStep newTail) {
    _tail?.next = newTail;
    newTail.prev = _tail;

    newTail.id = newStepId;

    _tail = newTail;

    _pastStepRepaint.notifyListeners();

    newTail.buildCache().then((success) {
      if (success) {
        DrawEmitter.inst.sendPast(newTail);
      } else {}
    });
  }

  void popTail() {
    // if past is empty, which mean nothing to undo
    if (_tail == null) return;

    var oldTail = _tail!;
    var newTail = oldTail.prev;

    oldTail.unlink();

    _tail = newTail;

    pastStepRepaint.notifyListeners();

    DrawEmitter.inst.removeStep(oldTail.id);
  }

  int _maxStepIdEver = 0;
  int get newStepId => _maxStepIdEver++;

  /// clear the past, current step unlink to tail (DrawStep constructor always link its prev to tail)
  void reset() {
    _tail = null;
    _maxStepIdEver = 0;
    _pastStepRepaint.notifyListeners();
  }

  DrawStep? _tail;
  DrawStep? get tail => _tail;
  //DrawStep? drawFrom;

  //#region only DrawStep can access this

  /// only FloodFillStep can access this
  ChangeNotifier get pastStepRepaint => _pastStepRepaint;
  //#endregion

  //bool get isEmpty => drawFrom == null;

  final ChangeNotifier _pastStepRepaint = ChangeNotifier();

  //#endregion
}

class _CurrentStepCustomPainter extends CustomPainter {
  _CurrentStepCustomPainter() : super(repaint: DrawManager.inst._currentStepRepaint);

  @override
  void paint(Canvas canvas, Size size) {
    DrawManager.inst.currentStep.draw(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PastStepCustomPainter extends CustomPainter {
  _PastStepCustomPainter() : super(repaint: DrawManager.inst._pastStepRepaint);

  @override
  void paint(Canvas canvas, Size size) {
    DrawManager.inst.tail?.drawBackward(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawWidgetCanvas extends StatelessWidget {
  const DrawWidgetCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    var drawInst = DrawManager.inst;
    var size = const Size(MainContent.width, MainContent.height);
    return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(3)),
        child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Obx(() => MouseRegion(
                cursor: DrawManager.inst.currentMode.cursor,
                child: GestureDetector(
                    onPanDown: (details) {
                      drawInst.currentStep.onDown(details.localPosition);
                    },
                    onPanUpdate: (details) {
                      drawInst.currentStep.onUpdate(details.localPosition);
                    },
                    onPanEnd: (_) => drawInst.onEnd(),
                    child: Stack(children: [
                      CustomPaint(size: size, painter: _PastStepCustomPainter()),
                      CustomPaint(size: size, painter: _CurrentStepCustomPainter())
                    ]))))));
  }
}
