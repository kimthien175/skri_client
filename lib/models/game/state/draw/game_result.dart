import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/game/game.dart';
import 'package:skribbl_client/models/gif_manager.dart';
import 'dart:math' as math;

class GameResult extends StatelessWidget {
  const GameResult({super.key, required this.visualization, required this.winnersTitle});

  final List<Widget> visualization;
  final List<Widget> winnersTitle;

  static void _bubbleInsert(List<Player> list, Player newItem) {
    for (var i = list.length - 1; i >= 0; i--) {
      if (list[i].score >= newItem.score) {
        // stop there
        list.insert(i + 1, newItem);
        return;
      }
    }

    // if code reach this line, which mean there newItem is the greatest at score
    list.insert(0, newItem);
  }

  static List<Player> _scoreBoardList() {
    List<Player> scoreBoardPlayers = [];

    var players = Game.inst.playersByMap;

    (Game.inst.status['bonus']['end_game'] as Map<String, dynamic>).forEach((id, rawPlayer) {
      var existingPlayer = players[id];
      if (existingPlayer != null) {
        existingPlayer.score = rawPlayer['score'];
      } else {
        // buble insertion
        existingPlayer = Player.fromJSON(rawPlayer);
      }

      _bubbleInsert(scoreBoardPlayers, existingPlayer);
    });

    return scoreBoardPlayers;
  }

  static Future<void> init() async {
    completer = Completer();

    var scoreBoardList = _scoreBoardList();
    var i = 0;

    //#region WINNER TITLE and TOP 1 visualization

    // clear crown
    Game.inst.playersByMap.forEach((id, player) => player.avatarModel.winner = false);

    var firstWinner = scoreBoardList.first;
    Game.inst.playersByMap[firstWinner.id]?.avatarModel.winner = true;

    List<Widget> winnersTitle = [
      Text(firstWinner.name, style: TextStyle(color: Colors.amber.shade200))
    ];
    List<Widget> visualization = [
      _PlayerVisualization.top1(player: firstWinner, head: true, tail: true)
    ];

    for (i = 1; i < scoreBoardList.length; i++) {
      var player = scoreBoardList[i];
      if (player.score == firstWinner.score) {
        winnersTitle.add(Text(' & '));
        winnersTitle.add(Text(player.name, style: TextStyle(color: Colors.amber.shade200)));
        visualization.add(_PlayerVisualization.top1(player: player, tail: true));

        Game.inst.playersByMap[player.id]?.avatarModel.winner = true;
      } else {
        break;
      }
    }
    winnersTitle.add(Text(" ${'is_the_winner'.tr}!"));
    //#endregion

    //#region TOP2
    if (i < scoreBoardList.length) {
      var firstTop2Winner = scoreBoardList[i];

      visualization.insert(0, _PlayerVisualization.top2(player: firstTop2Winner, head: true));

      for (i++; i < scoreBoardList.length; i++) {
        var player = scoreBoardList[i];
        if (player.score == firstTop2Winner.score) {
          visualization.insert(0, _PlayerVisualization.top2(player: player, head: true));
        } else {
          break;
        }
      }
    }
    //#endregion

    //#region TOP3
    if (i < scoreBoardList.length) {
      var firstTop3Winner = scoreBoardList[i];
      visualization.add(_PlayerVisualization.top3(player: firstTop3Winner, tail: true));
      for (i++; i < scoreBoardList.length; i++) {
        var player = scoreBoardList[i];
        if (player.score == firstTop3Winner.score) {
          visualization.add(_PlayerVisualization.top3(player: player, tail: true));
        } else {
          break;
        }
      }
    }
    //#endregion

    completer?.complete(GameResult(
      visualization: visualization,
      winnersTitle: winnersTitle,
    ));
  }

  static Completer<GameResult>? completer;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 60),
      DefaultTextStyle.merge(
          style: TextStyle(
              fontSize: 30, color: Colors.white, fontVariations: [FontVariation.weight(500)]),
          child: Wrap(alignment: WrapAlignment.center, children: winnersTitle)),
      Expanded(
          child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Wrap(
                      runAlignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      alignment: WrapAlignment.center,
                      children: visualization))))
    ]);
  }
}

class _PlayerVisualization extends StatelessWidget {
  _PlayerVisualization.top1({required this.player, this.head = false, this.tail = false}) {
    number = 1;
    color = Colors.yellow.shade400;
    height = 100;
    _avatar = Stack(clipBehavior: Clip.none, children: [
      Positioned(
          right: -40,
          bottom: 0,
          child: GifManager.inst.misc('trophy').builder.init().fit(height: 90, width: 90)),
      ParallelogramJump(child: player.avatarModel.builder.init().doScale(2.6))
    ]);
  }

  // ignore: unused_element_parameter
  _PlayerVisualization.top2({required this.player, this.head = false, this.tail = false}) {
    number = 2;
    color = Colors.white;
    height = 80;
    _avatar = player.avatarModel.builder.init().doScale(2.6);
  }

  // ignore: unused_element_parameter
  _PlayerVisualization.top3({required this.player, this.head = false, this.tail = false}) {
    number = 3;
    color = const Color.fromARGB(255, 211, 174, 162);
    height = 60;
    _avatar = player.avatarModel.builder.init().doScale(2.6);
  }
  final Player player;
  late final int number;
  late final Color color;
  final bool head;
  late final double height;
  final bool tail;
  late final Widget _avatar;
  @override
  Widget build(BuildContext context) {
    var style = TextStyle(color: color, fontSize: 15, fontVariations: [FontVariation.weight(700)]);

    return Column(children: [
      _avatar,
      CustomPaint(
          painter: _VisualStand(
              head: head,
              tail: tail,
              style: DefaultTextStyle.of(context).style.merge(style),
              number: number),
          child: SizedBox(
              width: 180,
              height: height,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(player.name, style: style),
                    Text("${player.score} ${'points'.tr}", style: style)
                  ])))
    ]);
  }

  static double strokeWidth = 4;
}

class _VisualStand extends CustomPainter {
  _VisualStand({this.head = false, this.tail = false, required this.style, required this.number});

  final bool head;
  final bool tail;

  final TextStyle style;

  final int number;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = style.color!
      ..style = PaintingStyle.stroke
      ..strokeWidth = _PlayerVisualization.strokeWidth;

    final path = Path();
    if (head) {
      path.moveTo(paint.strokeWidth / 2, size.height);

      path.lineTo(paint.strokeWidth / 2, 8);
      path.arcToPoint(Offset(8, paint.strokeWidth / 2),
          radius: Radius.circular(8), clockwise: true);

      path.lineTo(size.width - 8, paint.strokeWidth / 2);

      if (tail) {
        path.arcToPoint(Offset(size.width - paint.strokeWidth / 2, 8),
            radius: Radius.circular(8), clockwise: true);
        path.lineTo(size.width - paint.strokeWidth / 2, size.height);
      }
    } else if (tail) {
      path.moveTo(8, paint.strokeWidth / 2);

      path.lineTo(size.width - 8, paint.strokeWidth / 2);
      path.arcToPoint(Offset(size.width - paint.strokeWidth / 2, 8),
          radius: Radius.circular(8), clockwise: true);
      path.lineTo(size.width - paint.strokeWidth / 2, size.height);
    } else {
      path.moveTo(8, 0);
      path.lineTo(size.width - 8, 0);
    }

    canvas.drawPath(path, paint);

    // draw text on top left corner
    final textPainter = TextPainter(
        text: TextSpan(text: '#$number', style: style), textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, 8));
  }

  @override
  bool shouldRepaint(_VisualStand oldDelegate) => true;
}

class ParallelogramJump extends StatefulWidget {
  const ParallelogramJump({
    super.key,
    required this.child,
    this.boxSize = const Size(120, 80),
    this.jumpHeight = 100.0,
    this.angleDeg = 15.0,
    this.morphWidthStretch = 0.20, // +20% width at full morph
    this.morphHeightSquash = 0.20, // -20% height at full morph
    this.duration = const Duration(milliseconds: 1600),
    this.color = const Color(0xFF3B82F6),
  });

  final Widget child;
  final Size boxSize;
  final double jumpHeight;
  final double angleDeg;
  final double morphWidthStretch;
  final double morphHeightSquash;
  final Duration duration;
  final Color color;

  @override
  State<ParallelogramJump> createState() => _ParallelogramJumpState();
}

class _ParallelogramJumpState extends State<ParallelogramJump> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Phases (fractions of total duration)
  // A: morph-in (0 -> 0.18)
  // B: ascend & un-morph (0.18 -> 0.55)
  // C: descend (0.55 -> 0.95)
  // D: settle on ground (0.95 -> 1.0)
  static const _a = 0.18;
  static const _b = 0.55;
  static const _c = 0.95;

  late final Animation<double> _morph; // 0..1..0..0
  late final Animation<double> _y; // 0..0..-H..0
  late final Animation<double> _settle; // small landing pulse (0..1..0)

  int _dir = 1; // +1 = CCW / rightward, -1 = CW / leftward

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    _morph = TweenSequence<double>([
      // A: 0 -> 1
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: _a,
      ),
      // B: 1 -> 0 (unmorph during ascent)
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: _b - _a,
      ),
      // C: hold 0 during descent
      TweenSequenceItem(tween: ConstantTween(0.0), weight: _c - _b),
      // D: still 0 on ground
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 1 - _c),
    ]).animate(_ctrl);

    _y = TweenSequence<double>([
      // A: ground
      TweenSequenceItem(tween: ConstantTween(0.0), weight: _a),
      // B: ascend 0 -> -H
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -widget.jumpHeight)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: _b - _a,
      ),
      // C: descend -H -> 0
      TweenSequenceItem(
        tween:
            Tween(begin: -widget.jumpHeight, end: 0.0).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: _c - _b,
      ),
      // D: on ground
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 1 - _c),
    ]).animate(_ctrl);

    // tiny settle pulse at landing (optional)
    _settle = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: _c),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: (1 - _c) / 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: (1 - _c) / 2,
      ),
    ]).animate(_ctrl);

    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        // flip direction and run again
        _dir = -_dir;
        _ctrl.forward(from: 0);
      }
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final angle = widget.angleDeg * math.pi / 180.0;
    final shearTarget = math.tan(angle); // X-shear from Y

    return AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          // Morph amounts
          final morph = _morph.value; // 0..1
          // Width grows & height shrinks during morph
          final wScale = 1.0 + widget.morphWidthStretch * morph;
          final hScale = 1.0 - widget.morphHeightSquash * morph;

          // Skew towards the active direction only during morph
          final shear = shearTarget * morph * _dir;

          // Position along the fixed 15° direction: x tied to y using tan(15°)
          final y = _y.value;
          final x = _dir * y * math.tan(angle);

          // Optional tiny settle: a quick 0.98→1.0 scale when landing
          final settleScale = 1.0 - 0.02 * _settle.value;

          final m = Matrix4.identity()
            ..translateByDouble(x, y, 1, 1)
            ..scaleByDouble(wScale * settleScale, hScale * settleScale, 1, 1)
            // shear X as a function of Y (parallelogram), keep bottom edge fixed:
            ..setEntry(0, 1, shear);

          return Transform(
              alignment: Alignment.bottomCenter, // bottom edge stays put
              transform: m,
              child: widget.child);
        });
  }
}
