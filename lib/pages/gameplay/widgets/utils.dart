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

  Future<void> endCurrent() async {
    SocketIO.inst.socket.emit('draw:end_current');
  }
}

class DrawReceiver {
  static final DrawReceiver _inst = DrawReceiver._internal();
  static DrawReceiver get inst => _inst;

  DrawReceiver._internal();

  void reset() {
    pastSteps = {};
    _stepsBlackList = {};
    _archivedSteps = {};
    tailID = 0;
    currentStep = null;

    pastStepsNotifier.notifyListeners();
    currentStepNotifier.notifyListeners();
  }

  void load(dynamic drawData) async {
    if (drawData == null) {
      reset();
      return;
    }

    pastSteps = {};
    _stepsBlackList = {};
    _archivedSteps = {};

    tailID = drawData['tail_id'];

    startCurrent(drawData['current_step']);
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

  late int tailID;

  //#region Past steps
  late Map<int, DrawStep> pastSteps;

  final ChangeNotifier pastStepsNotifier = ChangeNotifier();

  void addToPastSteps(dynamic json) {
    if (_stepsBlackList.contains(json['secondary_id'])) return;

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
    step.secId = json['secondary_id'];

    // patch into linked list, the pastStep always is linked list itself ending with tail

    int? performerPrevID = json['prev_id'];
    int? performerNextID = json['next_id'];

    DrawStep? spectatorPrevStep;
    DrawStep? spectatorNextStep;

    //#region find spectatorPrevStep and spectatorNextStep
    var replacedTarget = pastSteps[step.id];
    if (replacedTarget != null) {
      spectatorPrevStep = replacedTarget.prev;
      spectatorNextStep = replacedTarget.next;

      _stepsBlackList.add(replacedTarget.secId);
    } else {
      //#region find spectatorPrevStep
      for (var i = performerPrevID ?? step.id - 1; i >= 0; i--) {
        spectatorPrevStep = pastSteps[i];
        if (spectatorPrevStep != null) break;
      }
      //#endregion

      //#region find spectatorNextStep
      for (var i = performerNextID ?? step.id + 1; i <= tailID; i++) {
        spectatorNextStep = pastSteps[i];
        if (spectatorNextStep != null) break;
      }
      //#endregion
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
    _archivedSteps[step.secId] = step;

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
  }

  /// keys as secondaryId, values as id
  late Set<String> _stepsBlackList;

  /// Store all `DrawStep` ever exist or even got deleted in `pastSteps`
  ///
  /// (not necessary to delete targets everytime a DrawStep get deleted or replaced to have the same children amount as `pastSteps`,
  ///
  /// if plan to have new feature as redo, then leave it be to be able to restore to `pastSteps`).
  ///
  /// `key` as `DrawStep.secondaryId`
  late Map<String, DrawStep> _archivedSteps;

  void removePastStep(String targetSecondaryId) {
    // check in black list firstly
    if (_stepsBlackList.contains(targetSecondaryId)) {
      // Case 1: which means already killed it or ignored it
      return;
    }

    // have to look in past steps for the target by 2nd id, when done, add to black list to prevent the name comes 1 more time
    // past step have keys as id, not 2nd id, i don't want to check every item in past step by 2nd id
    // have map<2nd id, DrawStep> , faster in looking it and kill it

    var target = _archivedSteps[targetSecondaryId];

    if (target == null) {
      // case 2: which means the target did not come early before the undo signal
      // add to black list for addToPastSteps to ignore
      _stepsBlackList.add(targetSecondaryId);
      return;
    }

    // case 3: found it, start to kill

    pastSteps.remove(target.id);

    _stepsBlackList.add(targetSecondaryId);
    //_stepsWhiteList.remove(targetSecondaryId);

    var prev = target.prev;
    // before unlink, check tailIO to set new one
    if (target.id == tailID) {
      tailID = prev != null ? prev.id : 0;
    }

    target.unlink();

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

  void endCurrent() {
    currentStep = null;
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
