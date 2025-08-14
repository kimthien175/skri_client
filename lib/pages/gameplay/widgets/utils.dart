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
  Future<void> sendPast(DrawStep newStep) async =>
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

    tailID = drawData['tail_id'];
    _initPastSteps(drawData['past_steps']);
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
        return;
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
    if (pastSteps[json['id']] != null) return;

    print('[NEW RAW STEP]');
    print(json['id']);
    print(json['prev_id']);
    print(json['next_id']);

    late DrawStep step;

    switch (json['type']) {
      case ClearStep.TYPE:
        step = ClearStep();
        break;

      case BrushStep.TYPE:
        step = BrushStep.fromJSON(json);
        break;

      case FullFillStep.TYPE:
        step = FullFillStep.fromJSON(json);
        break;

      case FloodFillStep.TYPE:
        step = FloodFillStep.fromJSON(json);
        break;

      default:
        return;
    }

    step.id = json['id'];

    // patch into linked list, the pastStep always is linked list itself ending with tail

    int? performerPrevID = json['prev_id'];
    DrawStep? spectatorPrevStep;

    //#region set spectatorPrevStep
    for (var i = performerPrevID ?? step.id - 1; i >= 0; i--) {
      spectatorPrevStep = pastSteps[i];
      if (spectatorPrevStep != null) break;
    }
    //#endregion

    int? performerNextID = json['next_id'];
    DrawStep? spectatorNextStep;

    //#region set nextStep
    for (var i = performerNextID ?? step.id + 1; i <= tailID; i++) {
      spectatorNextStep = pastSteps[i];
      if (spectatorNextStep != null) break;
    }
    //#endregion

    //#region patch newStep
    step.next = spectatorNextStep;
    step.prev = spectatorPrevStep;

    spectatorNextStep?.prev = step;
    spectatorPrevStep?.next = step;
    //#endregion

    if (step.id > tailID) {
      tailID = step.id;
    }

    pastSteps[step.id] = step;

    print('[NEW STEP AFTER PATCHING]');
    print(step);
    print(step.prev);
    print(step.next);

    // re render
    pastStepsNotifier.notifyListeners();

    // newStep is head, or its prevStep is really the previous of newStep
    if (performerPrevID == null ||
        (spectatorPrevStep != null && performerPrevID == spectatorPrevStep.id)) {
      step.buildCache();
    }

    // consider next step should build cache or not
    if (spectatorNextStep != null && spectatorNextStep.id == performerNextID) {
      spectatorNextStep.buildCache();
    }

    printFromTailToHead();
  }

  printFromTailToHead() {
    print('[PRINT CHAIN]');
    DrawStep? node = pastSteps[tailID];
    while (node != null) {
      print(node);
      node = node.prev;
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
    currentStep = step != null ? BrushStep.fromJSON(step) : null;
    currentStepNotifier.notifyListeners();
  }

  void updateCurrent(dynamic data) {
    if (currentStep == null) return;

    // update as BrushStep
    currentStep?.receivePoint(JSONOffset.fromJSON(data['point']));
    currentStepNotifier.notifyListeners();
  }

  //#endregion
  BrushStep? currentStep;

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
