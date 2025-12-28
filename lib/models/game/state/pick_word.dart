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
  Duration get _fullPickingDuration => Duration(seconds: Game.inst.system['pick_word_time']);
  PickWordState({required super.data});

  String get playerId => data['player_id'];
  List<dynamic>? get words => data['words'];
  bool get isPicker => MePlayer.inst.id == playerId;

  late int? roundNotify = data['round_notify'];

  @override
  Future<DateTime> onStart(DateTime startDate) async {
    var sinceStartDate = DateTime.now() - startDate;

    // required background
    topWidgetController.background = 1;

    var consumedDuration = TopWidgetController.contentDuration;

    //#region ROUND NOTI
    if (roundNotify != null) {
      Game.inst.currentRound.value = roundNotify!;

      topWidgetController.child.value = _TopWidget.roundNoti();

      //#region SHOW ROUND NOTI
      if (sinceStartDate < TopWidgetController.contentDuration) {
        // play sound
        Sound.inst.play(Sound.inst.roundStart);

        await topWidgetController.forwardContent(
          from: sinceStartDate / TopWidgetController.contentDuration,
        );

        sinceStartDate = Duration.zero;
      } else {
        topWidgetController.content = 1;
        sinceStartDate -= TopWidgetController.contentDuration;
      }
      //#endregion

      //#region WATI FOR DURATION
      if (sinceStartDate < waitDuration) {
        await topWidgetController.wait(waitDuration - sinceStartDate);
        sinceStartDate = Duration.zero;
      } else {
        sinceStartDate -= waitDuration;
      }
      //#endregion

      //#region REVERSE ROUND NOTI
      if (sinceStartDate < TopWidgetController.contentDuration) {
        await topWidgetController.reverseContent(
          from: 1 - sinceStartDate / TopWidgetController.contentDuration,
        );
        sinceStartDate = Duration.zero;
      } else {
        topWidgetController.content = 0;
        sinceStartDate -= TopWidgetController.contentDuration;
      }
      //#endregion

      consumedDuration += TopWidgetController.contentDuration * 2 + waitDuration;
    }
    //#endregion

    topWidgetController.child.value = _TopWidget.wordOptions();

    //#region FORWARD CONTENT
    if (sinceStartDate < TopWidgetController.contentDuration) {
      await topWidgetController.forwardContent(
        from: sinceStartDate / TopWidgetController.contentDuration,
      );
      sinceStartDate = Duration.zero;
    } else {
      sinceStartDate -= TopWidgetController.contentDuration;
      topWidgetController.content = 1;
    }
    //#endregion

    //#region START CLOCK
    var clockDuration = _fullPickingDuration - sinceStartDate;
    if (clockDuration > Duration.zero) {
      print('debugging pick word');
      Get.find<GameClockController>().countdown(
        clockDuration,
        onEnd: () {
          // send random word
          if (isPicker && _wordStatus == _WordSendingStatus.notSent) {
            var randomWordIndex = words != null ? Random().nextInt(words!.length) : null;
            sendWord(randomWordIndex);
          }
        },
      );
    }
    //#endregion

    return startDate.add(consumedDuration);
  }

  @override
  Duration get waitDuration => const Duration(seconds: 2);

  void sendWord(int? wordIndex) {
    _wordStatus = _WordSendingStatus.sending;
    SocketIO.inst.socket.emitWithAck('pick_word', wordIndex, ack: (data) {});
  }

  _WordSendingStatus _wordStatus = _WordSendingStatus.notSent;

  @override
  Future<DateTime> onEnd(DateTime endDate) async {
    if (Game.inst.endGameData != null) return super.onEnd(endDate);

    // require background
    topWidgetController.background = 1;

    var sinceEndDate = endDate.fromNow();

    //#region REVERSE CONTENT
    if (sinceEndDate < TopWidgetController.contentDuration) {
      await topWidgetController.reverseContent(
        from: 1 - sinceEndDate / TopWidgetController.contentDuration,
      );
      sinceEndDate = Duration.zero;
    } else {
      topWidgetController.content = 0;
      sinceEndDate -= TopWidgetController.contentDuration;
    }
    //#endregion

    //#region REVERSE BACKGROUND
    if (sinceEndDate < TopWidgetController.backgroundDuration) {
      await topWidgetController.reverseBackground(
        from: 1 - sinceEndDate / TopWidgetController.backgroundDuration,
      );

      // for spectators watching the transtion from PickWordState to DrawState, the draw data would reset
      // for spectator join mid game, of course this would be skipped
      DrawReceiver.inst.reset();
    } else {
      topWidgetController.background = 0;
    }
    //#endregion

    return endDate.add(
      TopWidgetController.contentDuration + TopWidgetController.backgroundDuration,
    );
  }

  @override
  void onClose() {
    Get.find<GameClockController>().cancel();
  }
}

enum _WordSendingStatus { notSent, sending }

class _WordButton extends StatefulWidget {
  const _WordButton({required this.wordIndex});

  final int wordIndex;

  @override
  State<_WordButton> createState() => __WordButtonState();
}

class __WordButtonState extends State<_WordButton> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<Color?> textAnimation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: AnimatedButton.duration);
    textAnimation = ColorTween(begin: Colors.white, end: Colors.grey.shade900).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    var state = Game.inst.state.value as PickWordState;
    return HoverButton(
      onTap: () {
        if (state._wordStatus == _WordSendingStatus.notSent) {
          Get.find<GameClockController>().cancel();
          state.sendWord(widget.wordIndex);
        }
      },
      border: Border.all(color: Colors.white, width: 2.5),
      controller: controller,
      color: Colors.transparent,
      hoverColor: Colors.white,
      child: ColorTransition(
        listenable: textAnimation,
        builder: (color) => Text(
          (Game.inst.state.value as PickWordState).words![widget.wordIndex],
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontVariations: [FontVariation.weight(700)],
            shadows: [],
          ),
        ),
      ),
    );
  }
}

class _WordOptions extends StatefulWidget {
  const _WordOptions({required this.words});

  final List<dynamic> words;

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
    List<Widget> wordButtons = [];
    for (var i = 0; i < widget.words.length; i++) {
      wordButtons.add(
        Padding(
          padding: EdgeInsets.all(8),
          child: UnconstrainedBox(child: _WordButton(wordIndex: i)),
        ),
      );
    }

    return FocusScope(
      node: focusNode,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: wordButtons,
      ),
    );
  }
}

class _TopWidget extends StatelessWidget {
  _TopWidget.roundNoti() {
    child = Text('round_noti'.trParams({'round': Game.inst.currentRound.value.toString()}));
  }

  _TopWidget.wordOptions() {
    var inst = Game.inst;
    var state = inst.state.value as PickWordState;
    var player = inst.playersByMap[state.playerId] ?? inst.quitPlayers[state.playerId]!;
    child = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: state.playerId == MePlayer.inst.id
          ? [
              Text('choose_a_word'.tr, style: TextStyle(color: Colors.grey.shade300)),
              _WordOptions(words: state.words ?? []),
            ]
          : [
              Text('player_choosing'.trParams({'playerName': player.name})),
              player.avatarModel.builder.initWithShadow().fit(height: 75),
            ],
    );
  }

  late final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(
        shadows: [ShadowInfo.shadow],
        color: Colors.white,
        fontSize: 32,
        fontVariations: [FontVariation.weight(480)],
      ),
      child: child,
    );
  }
}
