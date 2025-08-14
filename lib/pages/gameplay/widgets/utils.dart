// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:skribbl_client/utils/socket_io.dart';

import 'draw/step/brush.dart';
import 'draw/step/clear.dart';
import 'draw/step/fill/fill.dart';
import 'draw/step/step.dart';

class DrawEmitter {
  static DrawEmitter get inst => _inst;
  static final DrawEmitter _inst = DrawEmitter._internal();
  DrawEmitter._internal();

  /// insert step
  Future<void> emitStep(DrawStep newStep) async =>
      SocketIO.inst.socket.emit('draw:send_past', newStep.toJSON);

  //final Queue<Map<String, dynamic>> _errorOperations = Queue();

  /// remove step by id
  Future<void> removeStep(int stepID) async {
    SocketIO.inst.socket.emit('draw:remove_past', stepID);
  }

  Future<void> startCurrent(dynamic data) async {
    SocketIO.inst.socket.emit('draw:start_current', data);
  }

  Future<void> updateCurrent(dynamic data) async {
    SocketIO.inst.socket.emit('draw:update_current', data);
  }
}

class DrawReceiver {
  static final DrawReceiver _inst = DrawReceiver._internal();
  static DrawReceiver get inst => _inst;

  DrawReceiver._internal();

  Future<void> load(dynamic drawData) async {
    startCurrent(drawData['current_step']);
    //tailID = drawData['tail_id'];

    //   _initPastSteps(drawData['past_steps']);
  }

  // ignore: non_constant_identifier_names
  Future<void> _initPastSteps(dynamic past_steps) async {
    // convert json.past_steps into widget
    // add to pastSteps, also chain to linked list
    // start from tailID

    var rawStep = past_steps[tailID];

    while (rawStep != null) {
      addToPastSteps(rawStep);

      // get new raw step
      int? prevStepID = rawStep['prev_id'];

      if (prevStepID != null) {
        rawStep = _prevRawStep(past_steps, prevStepID);
      } else {
        // this step is performer head
        break;
      }
    }
  }

  dynamic _prevRawStep(dynamic rawPastSteps, int prevStepID) {
    if (prevStepID < 0) return null;

    var rawStep = rawPastSteps[prevStepID];

    if (rawStep != null) return rawStep;

    return _prevRawStep(rawPastSteps, prevStepID - 1);
  }

  int tailID = 0;

  //#region Past steps
  final Map<int, DrawStep> pastSteps = {};
  final ChangeNotifier pastStepsNotifier = ChangeNotifier();

  void addToPastSteps(dynamic json) {
    if (pastSteps[json['id'] as int] != null) return;

    late DrawStep newStep;

    switch (json['type']) {
      case ClearStep.TYPE:
        newStep = ClearStep();
        break;

      case BrushStep.TYPE:
        newStep = BrushStep.fromJSON(json);
        break;

      case FullFillStep.TYPE:
        newStep = FullFillStep.fromJSON(json);
        break;

      case FloodFillStep.TYPE:
        newStep = FloodFillStep.fromJSON(json);
        break;

      default:
        return;
    }

    newStep.id = json['id'];

    // patch into linked list, the pastStep always is linked list itself ending with tail

    int? performerPrevID = json['prev_id'];
    DrawStep? prevStep;

    //#region set prevStep
    if (performerPrevID == null) {
      for (var id = newStep.id - 1; id >= 0; id--) {
        prevStep = pastSteps[id];
        if (prevStep != null) break;
      }
    } else {
      prevStep = pastSteps[performerPrevID];
    }
    //#endregion

    int? performerNextID = json['next_id'];
    DrawStep? nextStep;

    //#region set nextStep
    if (performerNextID == null) {
      for (var id = newStep.id + 1; id <= tailID; id++) {
        nextStep = pastSteps[id];
        if (nextStep != null) break;
      }
    } else {
      nextStep = pastSteps[performerNextID];
    }
    //#endregion

    // patch newStep
    newStep.next = nextStep;
    newStep.prev = prevStep;

    nextStep?.prev = newStep;
    prevStep?.next = newStep;

    // re render
    pastStepsNotifier.notifyListeners();

    // newStep is head, or its prevStep is really the previous of newStep
    if (performerPrevID == null || (prevStep != null && performerPrevID == prevStep.id)) {
      newStep.buildCache();
    }

    // consider next step should build cache or not
    if (nextStep != null && performerNextID == nextStep.id) {
      nextStep.buildCache();
    }
  }

  void removePastStep(int targetID) {
    var target = pastSteps[targetID];
    if (target == null) return;

    target.prev?.next = target.next;
    target.next?.prev = target.prev;

    pastStepsNotifier.notifyListeners();
  }

  Future<void> startCurrent(dynamic step) async {
    if (currentStep != null) {
      if (step != null) {
        // case 1
        // replace ??
        return;
      }

      // case 2
      // currentStep != null, step ==null
      currentStep = null;
      return;
    }

    if (step != null) {
      // case 3
      currentStep = BrushStep.fromJSON(step);
      return;
    }

    // case 4
    // both are null, do nothing then

    return;
  }

  void updateCurrent(dynamic data) {
    if (currentStep == null) return;
    print('point');
    print(data);
    // currentStep?.receivePoint(JSONOffset.fromJSON(point));
    // currentStepNotifier.notifyListeners();
  }

  //#endregion
  BrushStep? _currentStep;
  BrushStep? get currentStep => _currentStep;

  set currentStep(BrushStep? newStep) {
    _currentStep = newStep;
    currentStepNotifier.notifyListeners();
  }

  final ChangeNotifier currentStepNotifier = ChangeNotifier();
}

extension JSONColor on Color {
  Map<String, dynamic> get toJSON => {'r': r, 'g': g, 'b': b, 'a': a};
  static Color fromJSON(Map<String, dynamic> json) =>
      Color.from(red: json['r'], green: json['g'], blue: json['b'], alpha: json['a']);
}

extension JSONList on List<Offset> {
  dynamic get toJSON => map((point) => point.toJSON).toList();
}

extension JSONOffset on Offset {
  dynamic get toJSON => {'x': dx, 'y': dy};

  static Offset fromJSON(dynamic json) => Offset(json['x'], json['y']);
}
