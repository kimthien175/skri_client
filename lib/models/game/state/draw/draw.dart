import 'dart:async';
import 'dart:math';
import 'dart:ui';

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
        ? SpectatorDrawState(data: data)
        : data['word_mode'] == _HiddenHintStatus.value
            ? _PerformerDrawState(data: data)
            : _EmittingPerformerDrawState(data: data);
  }
}

mixin DrawStateMixin on GameState {
  Map<String, int> get points => data['points'];

  String get hint => data['hint'];

  @override
  Widget get topWidget => WordResult();

  bool get isHintHidden => data['word_mode'] == _HiddenHintStatus.value;

  @override
  Future<void> onStart(Duration sinceStartDate) async {
    Get.find<GameClockController>().start(
        Duration(seconds: Game.inst.settings['draw_time']) - sinceStartDate,
        onEnd: () => onEnd(Duration.zero));
  }

  @override
  Future<Duration> onEnd(Duration sinceEndDate) async {
    Get.find<GameClockController>().cancel();
    var topWidget = Get.find<TopWidgetController>();
    // word reveal
    // ignore: invalid_use_of_protected_member
    _WordResultState._inst?.setState(() {});
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

  String get performerId => data['player_id'];
}

class SpectatorDrawState extends GameState with DrawStateMixin {
  SpectatorDrawState({required super.data}) {
    if (!isHintHidden) Get.put(HintController(hint: hint));
  }

  @override
  Widget get status => isHintHidden ? const _HiddenHintStatus() : const _VisibleHintStatus();

  @override
  Future<void> onStart(Duration sinceStartDate) async {
    super.onStart(sinceStartDate);

    Get.find<LikeAndDislikeController>().controller.forward();
  }

  @override
  void Function(String) get submitMessage => _submitMessage;
  late void Function(String) _submitMessage = (text) {
    if (isSending) return;
    isSending = true;

    SocketIO.inst.socket.emitWithAck('player_guess', text, ack: (guessResult) {
      if (guessResult == 'right') {
        // disabled chat when player guess right
        _submitMessage = (_) {};
        return;
      }
      if (guessResult == 'close') {
        if (isCloseHintNotified) return;
        Game.inst.addMessage((color) => MePlayerGuessClose(word: text, backgroundColor: color));
        isCloseHintNotified = true;
      }

      isSending = false;
    });
  };

  /// to reduce server overload
  bool isSending = false;

  bool isCloseHintNotified = false;
}

enum GuessResult {
  right('right'),
  close('close'),
  wrong('wrong');

  final String value;
  const GuessResult(this.value);
}

class HintController extends GetxController {
  HintController({required String hint}) {
    this.hint = hint.obs;
  }
  late RxString hint;

  void setHint(int charIndex, String char) {
    hint.value = hint.value.replaceRange(charIndex, charIndex + 1, char);
  }
}

class WordResult extends StatefulWidget {
  const WordResult({super.key});

  @override
  State<WordResult> createState() => _WordResultState();
}

class _WordResultState extends State<WordResult> {
  static _WordResultState? _inst;
  @override
  void initState() {
    super.initState();
    _inst = this;
  }

  _addWidgets(List<Widget> playersName, List<Widget> playersPoint, Player player, int point,
      {bool quitPlayer = false}) {
    late TextStyle? nameStyle;
    if (player.id == MePlayer.inst.id) {
      nameStyle = TextStyle(color: Colors.blue);
    } else if (quitPlayer) {
      nameStyle = TextStyle(color: Colors.white.withValues(alpha: 0.5));
    } else {
      nameStyle = null;
    }
    playersName.add(Container(
        constraints: BoxConstraints(minWidth: 100),
        child: Text('${player.name} :', style: nameStyle)));
    playersPoint.add(Text(point.toString(), style: const TextStyle(color: Colors.green)));
  }

  Widget _multiColumnScoreBoard(List<String> iDs, int from) {
    List<Widget> playersName = [];
    List<Widget> playersPoint = [];
    final pointsMap = (Game.inst.state.value as DrawStateMixin).points;
    var players = Game.inst.playersByMap;
    var quitPlayers = Game.inst.quitPlayers;
    // 2 columns
    int i = from;
    for (; i < from + 15; i++) {
      var player = players[iDs[i]];
      if (player != null) {
        _addWidgets(playersName, playersPoint, player, pointsMap[iDs[i]]!);
      } else {
        _addWidgets(playersName, playersPoint, quitPlayers[iDs[i]]!, pointsMap[iDs[i]]!,
            quitPlayer: true);
      }
    }

    List<Widget> playersName2 = [];
    List<Widget> playersPoint2 = [];
    var end = min(from + 30, iDs.length);
    for (; i < end; i++) {
      var player = players[iDs[i]];
      if (player != null) {
        _addWidgets(playersName2, playersPoint2, player, pointsMap[iDs[i]]!);
      } else {
        _addWidgets(playersName2, playersPoint2, quitPlayers[iDs[i]]!, pointsMap[iDs[i]]!,
            quitPlayer: true);
      }
    }
    // if from != 0 => show fading overlay on top
    // if i != iDs.length => show fading overlay on bottom

    Widget child = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: playersName),
      const SizedBox(width: 20),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: playersPoint),
      const SizedBox(width: 50),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: playersName2),
      const SizedBox(width: 20),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: playersPoint2),
    ]);

    List<Color> colors = [];
    List<double> stops = [];
    if (from != 0) {
      colors.addAll([Colors.transparent, Colors.black]);
      stops.addAll([0, 50 / DrawManager.height]);
    }
    if (i != iDs.length) {
      colors.addAll([Colors.black, Colors.transparent]);
      stops.addAll([1.0 - 50 / DrawManager.height, 1.0]);
    }
    if (colors.isNotEmpty) {
      child = ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
              stops: stops,
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn, // keep destination (child) with alpha mask
          child: child);
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    var bonus = Game.inst.status['bonus'] as String?;
    if (bonus == null) return Container();

    final players = Game.inst.playersByMap;
    final pointsMap = (Game.inst.state.value as DrawStateMixin).points;
    late final Widget scoreBoard;

    if (pointsMap.length <= 15) {
      // 1 column
      List<Widget> playersName = [];
      List<Widget> playersPoint = [];
      pointsMap.forEach((id, point) {
        var player = players[id];
        if (player != null) _addWidgets(playersName, playersPoint, player, point);
      });

      scoreBoard = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: playersName),
        const SizedBox(width: 20),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: playersPoint)
      ]);
    } else {
      final List<String> iDs = pointsMap.keys.toList();
      late int from;

      if (pointsMap[MePlayer.inst.id] == null || iDs.length <= 30) {
        from = 0;
      } else {
        var mePos = iDs.indexOf(MePlayer.inst.id);
        from = mePos - 15;
        if (from < 0) {
          from = 0;
        } else if (from > iDs.length - 30) {
          from = iDs.length - 30;
        }
      }
      scoreBoard = _multiColumnScoreBoard(iDs, from);
    }

    return DefaultTextStyle.merge(
        style: const TextStyle(
            color: Colors.white, fontSize: 20, fontVariations: [FontVariation.weight(700)]),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                  textBaseline: TextBaseline.alphabetic,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Text('the_word_is'.tr, style: const TextStyle(fontSize: 25)),
                    const SizedBox(width: 20),
                    Text(bonus,
                        style: const TextStyle(
                            fontSize: 40,
                            color: Colors.green,
                            fontVariations: [FontVariation.weight(750)]))
                  ]),
              const SizedBox(height: 18),
              scoreBoard
            ]));
  }
}
