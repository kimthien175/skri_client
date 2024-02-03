// ignore_for_file: invalid_use_of_protected_member,

import 'package:cd_mobile/pages/gameplay/widgets/draw/step/clear.dart';
import 'package:cd_mobile/pages/gameplay/widgets/draw/widgets/stroke_value_item.dart';
import 'package:cd_mobile/utils/socket_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'mode.dart';
import 'step/step.dart';
import 'widgets/color.dart';

class DrawTools extends GetxController {
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
  List<double> strokeSizeList = [0.2 * 20, (1 / 3) * 20, (5 / 9) * 20, (37 / 45) * 20, 1 * 20];

  late Color _currentColor;
  Color get currentColor => _currentColor;
  set currentColor(Color value) {
    _currentColor = value;
    DrawManager.inst._currentStep.changeColor(value);
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
    DrawManager.inst._currentStep.changeStrokeSize(value);
  }

  // ignore: unnecessary_cast
  final Rx<DrawMode> _currentMode = (BrushMode() as DrawMode).obs;
  DrawMode get currentMode => _currentMode.value;
  DrawStep get newCurrentStep => _currentMode.value.step(id: -2);

  set currentMode(DrawMode mode) {
    _currentMode.value = mode;
    DrawManager.inst._currentStep = newCurrentStep;
  }
}

class DrawManager extends ChangeNotifier {
  void onDown(Offset point) {
    _currentStep.onDown(point);
    notifyListeners();
  }

  void onUpdate(Offset point) {
    _currentStep.onUpdate(point);
    notifyListeners();
  }

  void onEnd() {
    if (!(_currentStep.onEnd())) return;

    _currentStep.id = pastSteps.length;
    pastSteps.add(_currentStep);

    _currentStep = DrawTools.inst.newCurrentStep;
  }

  void undo() {
    if (pastSteps.isEmpty) return;

    pastSteps.removeLast();

    lastStepRepaint.notifyListeners();
  }

  final ChangeNotifier lastStepRepaint = ChangeNotifier();
  void rerenderLastStep(){
    lastStepRepaint.notifyListeners();
  }

  void clear() {
    pastSteps.add(ClearStep(id: pastSteps.length));
    lastStepRepaint.notifyListeners();
    SocketIO.inst.socket.emit('draw:clear');
  }

  static const double width = 800;
  static const double height = 600;

  DrawStep _currentStep = DrawTools.inst.newCurrentStep;

  List<DrawStep> pastSteps = [];

  static DrawManager? _inst;
  static bool get isNull => _inst == null;
  static DrawManager get inst => _inst!;

  static init() {
    DrawTools.init();
    _inst = DrawManager._internal();
  }

  // singleton
  DrawManager._internal();
}

class CurrentStepCustomPainter extends CustomPainter {
  CurrentStepCustomPainter({super.repaint});
  final drawInst = DrawManager.inst;
  @override
  void paint(Canvas canvas, Size size) {
    drawInst._currentStep.drawAddon(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class LastStepCustomPainter extends CustomPainter{
  LastStepCustomPainter({super.repaint});
    final drawInst = DrawManager.inst;
  @override
  void paint(Canvas canvas, Size size) {
    if (drawInst.pastSteps.isNotEmpty){
      drawInst.pastSteps.last.draw(canvas);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>true;
}