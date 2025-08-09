// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:skribbl_client/pages/gameplay/widgets/draw/step/clear.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/widgets/stroke_value_item.dart';
import 'package:skribbl_client/utils/socket_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'mode.dart';
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
  GestureDrawStep get _newCurrentStep => _currentMode.value.stepFactory(id: 0);

  void onEnd(DragEndDetails _) {
    if (!currentStep.onEnd) return;

    // move step from current to past
    currentStep.id = pastSteps.length;
    pastSteps.add(currentStep);

    currentStep = _newCurrentStep;
  }

  void undo() {
    if (pastSteps.isEmpty) return;

    pastSteps.removeLast();

    pastStepRepaint.notifyListeners();
  }

  final ChangeNotifier currentStepRepaint = ChangeNotifier();
  final ChangeNotifier pastStepRepaint = ChangeNotifier();

  void rerenderLastStep() {
    pastStepRepaint.notifyListeners();
  }

  void reset() {
    pastSteps.clear();
    pastStepRepaint.notifyListeners();
  }

  void clear() {
    if (pastSteps.isEmpty) return;

    pastSteps.add(ClearStep(id: pastSteps.length));
    pastStepRepaint.notifyListeners();
    SocketIO.inst.socket.emit('draw:clear');
  }

  static const double width = 800;
  static const double height = 600;

  List<DrawStep> pastSteps = [];
}

class CurrentStepCustomPainter extends CustomPainter {
  CurrentStepCustomPainter({super.repaint});
  final drawInst = DrawManager.inst;
  @override
  void paint(Canvas canvas, Size size) {
    drawInst.currentStep.draw(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PastStepCustomPainter extends CustomPainter {
  PastStepCustomPainter({super.repaint});
  final drawInst = DrawManager.inst;
  @override
  void paint(Canvas canvas, Size size) {
    if (drawInst.pastSteps.isNotEmpty) {
      drawInst.pastSteps.last.drawRecursively(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
