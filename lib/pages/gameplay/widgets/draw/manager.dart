// ignore_for_file: invalid_use_of_protected_member,

import 'package:cd_mobile/pages/gameplay/widgets/draw/widgets/stroke_value_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'mode.dart';
import 'step.dart';
import 'widgets/color.dart';

class DrawTools extends GetxController{
  // singleton
  static init() {
    _inst = DrawTools._internal();
  }

  DrawTools._internal() {
    _currentColor = colorList[13];
    _currentStrokeSize = strokeSizeList[1];
  }
  static DrawTools? _inst;
  static DrawTools get inst => _inst!;

  List<Color> colorList = const [
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
  List<double> strokeSizeList = [
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
    DrawManager.inst._currentStep.value.changeColor(value);
    Get.find<RecentColorController>().addRecent();
    var mainStrokeItemController = Get.find<StrokeValueItemController>(tag: 'stroke_value_selector');
    mainStrokeItemController.value.refresh();
    mainStrokeItemController.isHovered.refresh();
  }

  late double _currentStrokeSize;
  double get currentStrokeSize => _currentStrokeSize;
  set currentStrokeSize(double value) {
    _currentStrokeSize = value;
    DrawManager.inst._currentStep.value.changeStrokeSize(value);
  }

  // ignore: unnecessary_cast
  final Rx<DrawMode> _currentMode = (BrushMode() as DrawMode).obs;
  DrawMode get currentMode => _currentMode.value;

  set currentMode(DrawMode mode) {
    _currentMode.value = mode;
    DrawManager.inst.setCurrentStep();
  }
}

class DrawManager extends GetxController {
  void onDown(Offset point) {
    _currentStep.value.onDown(point);
    repaint.notifyListeners();
  }

  void onUpdate(Offset point) {
    _currentStep.value.onUpdate(point);
    repaint.notifyListeners();
  }

  void onEnd() {
    if (!(_currentStep.value.onEnd())) return;

    // push the old current step into past steps
    _currentStep.value.id = pastSteps.length;
    pastSteps.add(_currentStep.value);
    // compile temp
    addToCompilingChain();

    setCurrentStep();
    //repaint.notifyListeners();
  }

  void undo() {
    if (pastSteps.isEmpty) return;
    // remove last step on pastSteps
    pastSteps.removeLast();

    // check current draw index
    if (pastSteps.length == drawnTempIndex.value) {
      decreaseDrawTempIndex();
    }
  }

  void clear() {
    pastSteps.add(ClearStep(id: pastSteps.length));
    drawnTempIndex.value = pastSteps.length - 1;
    // because the clear step make the compiling chain stop
    addToCompilingChain();
  }

  Future<void> addToCompilingChain() async {
    if (completedTempIndex.value == pastSteps.length - 2) {
      do {
        try {
          await pastSteps[completedTempIndex.value + 1].compileTemp();
          increaseCompletedTempIndex();
        } catch (e) {
          // print('sync e');
          // print(e);
          // await _fixErrorNodeAndContinue(1);

          // remove this node
          pastSteps.removeAt(completedTempIndex.value + 1);
          // fix drawnTempIndex
          if (pastSteps.last is ClearStep) {
            drawnTempIndex.value--;
          }

          for (int i = completedTempIndex.value + 1; i < pastSteps.length; i++) {
            pastSteps[i].id--;
          }
        }
      } while (completedTempIndex.value < pastSteps.length - 1);
    }
  }

  static const double width = 800;
  static const double height = 600;

  RxInt completedTempIndex = (-1).obs;
  RxInt drawnTempIndex = (-1).obs;

  void decreaseDrawTempIndex() {
    drawnTempIndex.value--;
    // < : completedTempIndex = drawTempIndex
    // = : ok
    // > : set drawTempIndex = completedTEmpIndex
    if (drawnTempIndex.value < completedTempIndex.value) {
      completedTempIndex.value = drawnTempIndex.value;
    } else if (drawnTempIndex.value > completedTempIndex.value) {
      drawnTempIndex.value = completedTempIndex.value;
    }
    repaint.notifyListeners();
  }

  void increaseCompletedTempIndex() {
    completedTempIndex.value++;
    // hey i'm newer, point to me to draw the new one
    if (completedTempIndex.value > drawnTempIndex.value) {
      drawnTempIndex.value = completedTempIndex.value;
    }
    repaint.notifyListeners();
  }

  final Rx<DrawStep> _currentStep = DrawTools.inst.currentMode.step(id: -2).obs;
  void setCurrentStep() {
    _currentStep.value = DrawTools.inst.currentMode.step(id: -2);
  }

  List<DrawStep> pastSteps = [];

  static DrawManager? _inst;
  static bool get isNull => _inst == null;
  static DrawManager get inst => _inst!;

  ChangeNotifier repaint = ChangeNotifier();

  static init() {
    DrawTools.init();
    _inst = DrawManager._internal();
  }

  // singleton
  DrawManager._internal();
}

class DrawStepCustomPainter extends CustomPainter {
  DrawStepCustomPainter({super.repaint});
  final drawInst = DrawManager.inst;
  @override
  void paint(Canvas canvas, Size size) {
    // draw temp in pastSteps
    if (drawInst.drawnTempIndex.value != -1) {
      drawInst.pastSteps[drawInst.drawnTempIndex.value].drawTemp(canvas);
    }
    drawInst._currentStep.value.drawCurrent(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
