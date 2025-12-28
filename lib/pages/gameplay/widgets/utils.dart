// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';

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

  Future<void> endCurrent(int privateId) async {
    SocketIO.inst.socket.emit('draw:end_current', privateId);
  }
}

class DrawReceiver {
  static final DrawReceiver _inst = DrawReceiver._internal();
  static DrawReceiver get inst => _inst;

  DrawReceiver._internal();

  void reset() {
    pastSteps = {};
    _stepsBlackList = {};
    tail = null;
    _head = null;

    currentStep = {};
    _brushBlackList = {};

    pastStepsNotifier.notifyListeners();
    currentStepNotifier.notifyListeners();
  }

  void load(dynamic drawData) async {
    //     if (drawData == null) {
    //       reset();
    //       return;
    //     }

    //     pastSteps = {};
    //     _stepsBlackList = {};

    //     currentStep = {};
    //     _brushBlackList = {};
    reset();

    startCurrent(drawData['current_step']);
    _initPastSteps(drawData['past_steps'], drawData['tail_id']);
  }

  // ignore: non_constant_identifier_names
  Future<void> _initPastSteps(dynamic past_steps, int? tailId) async {
    // convert json.past_steps into widget
    // add to pastSteps, also chain to linked list
    // start from tailID

    // server told you there is no tail, which means data is empty
    if (tailId == null) return;

    var rawStep = past_steps[tailId];

    while (rawStep != null) {
      addToPastSteps(rawStep);

      int? prevStepId = rawStep['prev_id'];

      if (prevStepId != null) {
        rawStep = _getStepBackward(past_steps, prevStepId);
      } else {
        return;
      }
    }
  }

  // ignore: non_constant_identifier_names
  dynamic _getStepBackward(dynamic past_steps, stepId) {
    if (stepId < 0) return null;
    return past_steps[stepId] ?? _getStepBackward(past_steps, stepId - 1);
  }

  DrawStep? tail;
  //#region Past steps
  late Map<int, DrawStep> pastSteps;

  final ChangeNotifier pastStepsNotifier = ChangeNotifier();

  void addToPastSteps(dynamic json) {
    var id = json['id'];

    // if blacklist has it, ignore
    if (_stepsBlackList.contains(id) || pastSteps[id] != null) return;

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

    step.id = id;

    step.performerPrevID = json['prev_id'];

    //#region IF FIRST SPECTATOR STEP THEN SET HEAD AND TAIL
    if (tail == null) {
      tail = step;
      _head = step;
      pastSteps[step.id] = step;
      pastStepsNotifier.notifyListeners();

      _updateBrushStep(step);

      if (step.performerPrevID == null) {
        step.buildCache();
      }

      return;
    }
    //#endregion

    //#region IF STEP IS SPECTATOR HEAD
    assert(_head != null);
    if (id < _head!.id) {
      if (_head!.performerPrevID == null || _head!.performerPrevID! < id) {
        // current performer head is newer, or step is in old branch, ignore
        _stepsBlackList.add(id);
        return;
      }

      // ok now, add head
      step.next = _head;
      _head!.prev = step;

      pastSteps[id] = step;
      _head = step;

      pastStepsNotifier.notifyListeners();
      _updateBrushStep(step);

      if (step.performerPrevID == null) {
        step.buildCache();
      }
      if (step.next?.performerPrevID == id) {
        step.next?.buildCache();
      }
      return;
    }
    //#endregion

    //#region IF STEP IS SPECTATOR TAIL
    assert(tail != null);
    if (tail!.id < id) {
      var pPrevId = step.performerPrevID;
      if (pPrevId == null) {
        // latest performer head, clear all and set step as first step
        pastSteps.clear();
        _head = step;
        tail = step;
        pastSteps[id] = step;
        pastStepsNotifier.notifyListeners();
        _updateBrushStep(step);
        step.buildCache();
        return;
      }

      // remove steps after pPrev, cause they are old branch
      var oldBranchStep = tail;
      while (oldBranchStep != null && oldBranchStep.id > pPrevId) {
        // delete oldBranchStep
        pastSteps.remove(oldBranchStep.id);
        _stepsBlackList.add(oldBranchStep.id);
        oldBranchStep = oldBranchStep.prev;
      }

      // spectatorPrev at this line is oldBranchStep
      if (oldBranchStep != null) {
        // patch with this
        oldBranchStep.next = step;
        step.prev = oldBranchStep;

        pastSteps[id] = step;
        tail = step;

        pastStepsNotifier.notifyListeners();
        _updateBrushStep(step);

        if (pPrevId == oldBranchStep.id) {
          step.buildCache();
        }
        return;
      }

      // new step is head as well
      // spectatorPrev == null which means pastSteps is already empty
      _head = step;
      tail = step;
      pastSteps[id] = step;
      pastStepsNotifier.notifyListeners();
      _updateBrushStep(step);
      // pPrev != null which mean no need to build cache
      return;
    }
    //#endregion

    //#region FINAL CASE: STEP STAY IN THE MIDDLE
    assert(_head != null && tail != null);
    var pPrevId = step.performerPrevID;
    DrawStep? spectatorNext;

    for (var i = id + 1; i <= tail!.id; i++) {
      spectatorNext = pastSteps[i];
      if (spectatorNext != null) {
        // step is in old branch, which mean found spectatorNext is new branch, then ignore
        // and since spectatorNext always has DrawStep before it, which mean its performerPrevId is always != null,
        // other wise it would be spectatorHead base on case 2, not this case
        if (spectatorNext.performerPrevID! < id) {
          _stepsBlackList.add(id);
          return;
        }
        break;
      }
    }

    // step stay in the middle, which mean spectatorNext always != null
    var prevTarget = spectatorNext!.prev;

    // new performer head
    if (pPrevId == null) {
      // for step as new head, then delete everything backward starts from spectatorPrev
      while (prevTarget != null) {
        pastSteps.remove(prevTarget.id);
        _stepsBlackList.add(prevTarget.id);
        prevTarget = prevTarget.prev;
      }

      // patch and set head
      step.next = spectatorNext;
      spectatorNext.prev = step;

      _head = step;

      pastSteps[id] = step;

      pastStepsNotifier.notifyListeners();
      _updateBrushStep(step);

      // new performer head, which mean it's time to build cache
      step.buildCache();
      if (spectatorNext.performerPrevID == id) {
        spectatorNext.buildCache();
      }
      return;
    }

    // not performer head
    // delete everything backward from prevTarget to the step after pPrev cause it is old branch
    while (prevTarget != null && pPrevId < prevTarget.id) {
      pastSteps.remove(prevTarget.id);
      _stepsBlackList.add(prevTarget.id);
      prevTarget = prevTarget.prev;
    }

    // prevTarget maybe null due to the head maybe in old branch as well
    if (prevTarget != null) {
      // patch with this
      prevTarget.next = step;
      step.prev = prevTarget;
    } else {
      _head = step;
    }

    // patch next
    spectatorNext.prev = step;
    step.next = spectatorNext;

    pastSteps[id] = step;

    pastStepsNotifier.notifyListeners();
    _updateBrushStep(step);

    if (prevTarget != null && prevTarget.id == pPrevId) step.buildCache();
    if (spectatorNext.performerPrevID == id) spectatorNext.buildCache();

    //#endregion
  }

  DrawStep? _head;

  late Set<int> _stepsBlackList;

  void removePastStep(int targetId) {
    if (_stepsBlackList.contains(targetId)) return;

    var target = pastSteps[targetId];

    if (target == null) {
      // add to black list for addToPastSteps to ignore
      _stepsBlackList.add(targetId);
      return;
    }

    if (tail == target) {
      tail = target.prev;
      if (tail == null) _head = null;
    } else if (_head == target) {
      _head = target.next;
      if (_head == null) tail == null;
    }

    target.unlink();

    pastSteps.remove(targetId);
    _stepsBlackList.add(targetId);

    pastStepsNotifier.notifyListeners();
    _updateBrushStep(target);
  }

  Future<void> startCurrent(dynamic step) async {
    if (step == null) return;
    if (_brushBlackList.contains(step['private_id'])) return;

    currentStep.clear();

    var brush = SpectatorBrushStep.fromJSON(step);
    currentStep[brush.privateId] = brush;

    currentStepNotifier.notifyListeners();
  }

  void updateCurrent(dynamic data) {
    // update as BrushStep
    var step = currentStep[data['private_id']];
    if (step != null) {
      step.receivePoint(data);
      currentStepNotifier.notifyListeners();
    }
  }

  Future<void> endCurrent(int privateId) async {
    var target = currentStep[privateId];
    if (target == null) {
      _brushBlackList.add(privateId);
      return;
    }
    await target.clear.future;
    currentStep.remove(privateId);
    currentStepNotifier.notifyListeners();
  }

  //#endregion

  late Map<int, SpectatorBrushStep> currentStep;

  late Set<int> _brushBlackList;

  void _updateBrushStep(DrawStep step) async {
    if (step is BrushStep) {
      var brush = currentStep[step.privateId];
      if (brush == null) {
        _brushBlackList.add(step.privateId);
        return;
      }

      brush.clear.complete();
    }
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
