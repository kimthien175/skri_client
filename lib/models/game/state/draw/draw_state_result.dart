import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/game/game.dart';
import 'dart:math' as math;

import 'package:skribbl_client/pages/gameplay/widgets/draw/manager.dart';

class DrawStateResult extends StatelessWidget {
  const DrawStateResult({super.key, required this.scoreBoard, required this.word});

  static void _addWidgets(
    List<Widget> playersName,
    List<Widget> playersPoint,
    Player player,
    int point,
  ) {
    playersName.add(_ScoredPlayerName(player: player));
    var pointText = point == 0
        ? Text('0', style: TextStyle(color: Colors.red))
        : Text('+$point', style: const TextStyle(color: Colors.green));
    playersPoint.add(pointText);
  }

  static Future<DrawStateResult> init() async {
    var endStateData = Game.inst.status['bonus']['end_state'];
    final players = Game.inst.playersByMap;
    var pointsMap = endStateData['score'] as Map<String, dynamic>;
    late Widget scoreBoard;

    if (pointsMap.length <= 15) {
      // 1 column
      List<Widget> playersName = [];
      List<Widget> playersPoint = [];
      pointsMap.forEach((id, point) {
        var player = players[id];
        if (player != null) _addWidgets(playersName, playersPoint, player, point);
      });

      // add some player with no point
      for (var entry in players.entries) {
        if (playersName.length == 15) break;
        if (pointsMap[entry.key] == null) {
          // this is player with no point
          _addWidgets(playersName, playersPoint, entry.value, 0);
        }
      }

      scoreBoard = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: playersName),
          const SizedBox(width: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: playersPoint),
        ],
      );
    } else {
      List<String> iDs = [];
      pointsMap.forEach((id, point) {
        if (players[id] != null) iDs.add(id);
      });

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

      //#region build score board
      List<Widget> playersName = [];
      List<Widget> playersPoint = [];

      // 2 columns
      int i = from;
      for (; i < 15 + from; i++) {
        _addWidgets(playersName, playersPoint, players[iDs[i]]!, pointsMap[iDs[i]]!);
      }

      List<Widget> playersName2 = [];
      List<Widget> playersPoint2 = [];

      var end = math.min(30 + from, iDs.length);
      for (; i < end; i++) {
        _addWidgets(playersName2, playersPoint2, players[iDs[i]]!, pointsMap[iDs[i]]!);
      }

      // add some player with no point
      for (var entry in players.entries) {
        if (playersName2.length == 15) break;
        if (pointsMap[entry.key] == null) {
          // this is player with no point
          _addWidgets(playersName2, playersPoint2, entry.value, 0);
        }
      }

      // if from != 0 => show fading overlay on top
      // if i != iDs.length => show fading overlay on bottom

      scoreBoard = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: playersName),
          const SizedBox(width: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: playersPoint),
          const SizedBox(width: 50),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: playersName2),
          const SizedBox(width: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: playersPoint2),
        ],
      );

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

      // if from != 0 => show fading overlay on top
      // if i != iDs.length => show fading overlay on bottom

      if (colors.isNotEmpty) {
        scoreBoard = ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
              stops: stops,
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn, // keep destination (child) with alpha mask
          child: scoreBoard,
        );
      }

      //#endregion
    }

    return DrawStateResult(scoreBoard: scoreBoard, word: endStateData['word']);
  }

  final String word;
  final Widget scoreBoard;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontVariations: [FontVariation.weight(700)],
      ),
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
              Text(
                word,
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.green,
                  fontVariations: [FontVariation.weight(750)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          scoreBoard,
        ],
      ),
    );
  }
}

class _ScoredPlayerName extends StatelessWidget {
  const _ScoredPlayerName({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 100),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: player.name,
                  style: (player.id == MePlayer.inst.id) ? TextStyle(color: Colors.blue) : null,
                ),
                const TextSpan(
                  text: ' :',
                  style: TextStyle(color: Color.from(alpha: 0.6, red: 1, green: 1, blue: 1)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
