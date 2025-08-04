import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/utils.dart';
import 'package:skribbl_client/widgets/widgets.dart';

class PickWordState extends GameState {
  Duration get _fullPickingDuration =>
      Duration(seconds: Game.inst.system['pick_word_time']);
  PickWordState({required super.data});

  String get playerId => data['player_id'];
  List<dynamic> get words => data['words'];
  bool get isPicker => MePlayer.inst.id == playerId;

  @override
  Widget get topWidget => DefaultTextStyle.merge(
      style: TextStyle(
          shadows: [ShadowInfo.shadow],
          color: Colors.white,
          fontSize: 32,
          fontVariations: [FontVariation.weight(480)]),
      child:
          roundNotify != null ? _topWidgetRoundNotify : _topWidgetChooseWord);

  Widget get _topWidgetRoundNotify => Text(
        'round_noti'
            .trParams({'round': Game.inst.currentRound.value.toString()}),
      );

  Widget get _topWidgetChooseWord {
    var player = Game.inst.playersByMap[playerId]!;
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: playerId == MePlayer.inst.id
            ? [
                Text('choose_a_word'.tr,
                    style: TextStyle(color: Colors.grey.shade300)),
                const _WordOptions()
              ]
            : [
                Text(
                  'player_choosing'.trParams({'playerName': player.name}),
                ),
                player.avatarModel.builder.initWithShadow().fit(height: 75)
              ]);
  }

  late int? roundNotify = data['round_notify'];

  void changeTopWidget() {
    roundNotify = null;
    Game.inst.state.refresh();
  }

  @override
  Future<void> onStart(Duration sinceStartDate) async {
    var topWidget = Get.find<TopWidgetController>();
    assert(topWidget.backgroundController.value == 1);

    //#region ROUND NOTI
    if (roundNotify != null) {
      // show round intro
      if (sinceStartDate < TopWidgetController.contentDuration) {
        await topWidget.contentController.forward(
            from: sinceStartDate / TopWidgetController.contentDuration);
        sinceStartDate = Duration.zero;
      } else {
        sinceStartDate -= TopWidgetController.contentDuration;
      }

      // hold round intro for 1s - contentDuration
      if (sinceStartDate < _roundNotiDuration) {
        topWidget.contentController.value = 1;
        await Future.delayed(const Duration(seconds: 1) - sinceStartDate);
        sinceStartDate = Duration.zero;
      } else {
        sinceStartDate -= _roundNotiDuration;
      }

      // close up round noti
      if (sinceStartDate < TopWidgetController.contentDuration) {
        await topWidget.contentController.reverse(
            from: 1 - sinceStartDate / TopWidgetController.contentDuration);
        sinceStartDate = Duration.zero;
      } else {
        sinceStartDate -= TopWidgetController.contentDuration;
      }

      changeTopWidget();
    }
    //#endregion

    if (sinceStartDate < TopWidgetController.contentDuration) {
      await topWidget.contentController
          .forward(from: sinceStartDate / TopWidgetController.contentDuration);
      sinceStartDate = Duration.zero;
    } else {
      sinceStartDate -= TopWidgetController.contentDuration;
      topWidget.contentController.value = 1;
    }

    var clockController = Get.find<GameClockController>();

    clockController.start(_fullPickingDuration - sinceStartDate, onEnd: () {
      clockController.cancel();
      // send random word
      if (isPicker && _wordStatus == _WordSendingStatus.notSent) {
        sendWord(words[Random().nextInt(words.length)]);
      }
    });
  }

  Duration get _roundNotiDuration => const Duration(seconds: 1);

  void sendWord(String word) {
    _wordStatus = _WordSendingStatus.sending;
    SocketIO.inst.socket.emitWithAck('pick_word', word, ack: (data) {
      if (!data['success']) {
        //  TODO
        throw Exception('pick word error');
      }
    });
  }

  _WordSendingStatus _wordStatus = _WordSendingStatus.notSent;

  @override
  Future<Duration> onEnd(Duration sinceEndDate) async {
    Get.find<GameClockController>().cancel();

    var topWidget = Get.find<TopWidgetController>();

    if (sinceEndDate < TopWidgetController.contentDuration) {
      await topWidget.contentController.reverse(
          from: 1 - sinceEndDate / TopWidgetController.contentDuration);
      sinceEndDate = Duration.zero;
    } else {
      topWidget.contentController.value = 0;
      sinceEndDate -= TopWidgetController.contentDuration;
    }

    if (sinceEndDate < TopWidgetController.backgroundDuration) {
      await topWidget.backgroundController.reverse(
          from: 1 - sinceEndDate / TopWidgetController.backgroundDuration);
      return Duration.zero;
    } else {
      topWidget.backgroundController.value = 0;
      return sinceEndDate - TopWidgetController.backgroundDuration;
    }
  }
}

enum _WordSendingStatus { notSent, sending }

class _WordButton extends StatefulWidget {
  const _WordButton({required this.word});

  final String word;

  @override
  State<_WordButton> createState() => __WordButtonState();
}

class __WordButtonState extends State<_WordButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<Color?> textAnimation;
  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: AnimatedButton.duration);
    textAnimation = ColorTween(begin: Colors.white, end: Colors.grey.shade900)
        .animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    var state = Game.inst.state.value as PickWordState;
    return HoverButton(
        onTap: () {
          if (state._wordStatus == _WordSendingStatus.notSent) {
            Get.find<GameClockController>().cancel();
            state.sendWord(widget.word);
          }
        },
        border: Border.all(color: Colors.white, width: 2.5),
        controller: controller,
        color: Colors.transparent,
        hoverColor: Colors.white,
        child: ColorTransition(
            listenable: textAnimation,
            builder: (color) => Text(widget.word,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontVariations: [FontVariation.weight(700)],
                    shadows: []))));
  }
}

class _WordOptions extends StatefulWidget {
  const _WordOptions();

  @override
  State<_WordOptions> createState() => __WordOptionsState();
}

class __WordOptionsState extends State<_WordOptions> {
  late final FocusScopeNode focusNode;
  @override
  void initState() {
    super.initState();
    focusNode = FocusScopeNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            focusNode.unfocus();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );

    focusNode.requestFocus();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
        node: focusNode,
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: (Game.inst.state.value as PickWordState)
                .words
                .map((e) => Padding(
                    padding: EdgeInsets.all(8),
                    child: _WordButton(word: e as String)))
                .toList()));
  }
}
