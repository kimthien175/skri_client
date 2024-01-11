import 'package:cd_mobile/models/game_play/player.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:cd_mobile/widgets/animated_button.dart';
import 'package:flutter/material.dart';

// TODO: LOAD PLAYERS INFO FROM GAME.INST
class GamePlayers extends StatelessWidget {
  const GamePlayers({super.key});

  @override
  Widget build(BuildContext context) {
    Player smt = MePlayer.inst;

    var players = [smt, smt, smt, smt, smt];
    List<PlayerCard> list = [];

    if (players.length > 1) {
      list.add(PlayerCard(
        index: 0,
        info: players[0],
        borderRadius:
            const BorderRadius.only(topLeft: Radius.circular(3), topRight: Radius.circular(3)),
      ));
      for (int i = 1; i < players.length - 1; i++) {
        list.add(PlayerCard(index: i, info: players[i]));
      }
      list.add(PlayerCard(
        index: players.length - 1,
        info: players[players.length - 1],
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(3), bottomRight: Radius.circular(3)),
      ));
    } else {
      list.add(PlayerCard(
          borderRadius: const BorderRadius.all(Radius.circular(3)), index: 0, info: players[0]));
    }

    return Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(3))),
        width: 200,
        child: Column(children: list));
  }
}

// TODO: CLICK TO SHOW PLAYER INFO IN
class PlayerCard extends StatelessWidget {
  const PlayerCard({this.borderRadius, required this.info, required this.index, super.key});
  final Player info;
  final BorderRadiusGeometry? borderRadius;
  final int index;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => showDialog(
            context: context,
            builder: (ctx) =>
                AlertDialog(title: Text(info.nameForCard), content: const Text('hello world'))),
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Stack(clipBehavior: Clip.none, children: [
              Container(
                  decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      color: index % 2 == 0
                          ? GameplayStyles.colorPlayerBGBase
                          : GameplayStyles.colorPlayerBGBase_2),
                  height: 48,
                  width: 200,
                  //alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(info.nameForCard,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: GameplayStyles.colorPlayerMe,
                              height: 1.1)),
                      const Text('0 points',
                          style: TextStyle(fontSize: 12.6, height: 1, fontWeight: FontWeight.w700))
                    ],
                  )),
              Positioned(
                  top: -1,
                  right: 0,
                  child: AnimatedButton(
                      minOpacity: 1, child: info.avatar.doFitSize(height: 48, width: 48))),
              Positioned(
                  top: 5,
                  left: 6,
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(fontSize: 15.4, fontWeight: FontWeight.w900),
                  )),
              if (info.isOwner)
                Positioned(
                    bottom: 0,
                    left: 4,
                    child:
                        Opacity(opacity: 0.6, child: GifManager.inst.misc('owner').builder.init()))
            ])));
  }
}
