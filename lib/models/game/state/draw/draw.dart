import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skribbl_client/models/models.dart';

import 'package:get/get.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/draw_widget.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/manager.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/utils.dart';

part 'performer.dart';
part 'widgets.dart';

abstract class DrawState {
  static GameState init({required dynamic data}) {
    return data['player_id'] != MePlayer.inst.id
        ? _SpectatorDrawState(data: data)
        : data['word_mode'] == _HiddenHintStatus.value
            ? _PerformerDrawState(data: data)
            : _EmittingPerformerDrawState(data: data);
  }
}

mixin _DrawStateMixin on GameState {
  String get hint => data['hint'];

  @override
  Widget get topWidget => const SizedBox();

  bool get isHintHidden => data['word_mode'] == _HiddenHintStatus.value;

  @override
  Future<void> onStart(Duration sinceStartDate) async {
    Get.find<GameClockController>()
        .start(Duration(seconds: Game.inst.settings['draw_time']) - sinceStartDate);
  }

  @override
  Future<Duration> onEnd(Duration sinceEndDate) async {
    var topWidget = Get.find<TopWidgetController>();
    // word reveal
    if (sinceEndDate < TopWidgetController.backgroundDuration) {
      await topWidget.forwardBackground(
          from: sinceEndDate / TopWidgetController.backgroundDuration);
      sinceEndDate = Duration.zero;
    } else {
      topWidget.background = 1;
      sinceEndDate -= TopWidgetController.backgroundDuration;
    }

    if (sinceEndDate < TopWidgetController.contentDuration) {
      await topWidget.contentController
          .forward(from: sinceEndDate / TopWidgetController.contentDuration);
      return Duration.zero;
    } else {
      topWidget.contentController.value = 1;
      return sinceEndDate - TopWidgetController.contentDuration;
    }
  }
}

class _SpectatorDrawState extends GameState with _DrawStateMixin {
  _SpectatorDrawState({required super.data});

  @override
  Widget get status => isHintHidden ? const _HiddenHintStatus() : const _VisibleHintStatus();

  @override
  Future<void> onStart(Duration sinceStartDate) async {
    super.onStart(sinceStartDate);

    DrawViewManager.inst.clear(null);
    Get.find<LikeAndDislikeController>().controller.forward();
  }
}
