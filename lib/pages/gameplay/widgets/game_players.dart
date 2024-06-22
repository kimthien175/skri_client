import 'package:cd_mobile/models/game/player.dart';
import 'package:cd_mobile/models/gif/avatar/model.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:cd_mobile/widgets/animated_button/builder.dart';
import 'package:cd_mobile/widgets/animated_button/decorators/scale.dart';
import 'package:flutter/material.dart';

class GamePlayers extends StatelessWidget {
  const GamePlayers({super.key});

  @override
  Widget build(BuildContext context) {
    //return Obx(() {
    // var players = Game.inst.playersByList;
    List<PlayerCard> list = [];

    for (int i = 1; i < 6; i++) {
      list.add(PlayerCard(
          index: i,
          info: Player(
              id: 'id',
              name: 'wrath',
              isOwner: false,
              avatar: AvatarModel.init(0, 0, 0).builder.init())
          //players[0]
          ));
    }

    return ClipRRect(borderRadius: BorderRadius.circular(10), child: Column(children: list));
    //});
  }
}

class PlayerCard extends StatelessWidget {
  const PlayerCard({required this.info, required this.index, super.key});
  final Player info;
  final int index;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => showDialog(
            context: context,
            builder: (ctx) =>
                AlertDialog(title: Text(info.nameForCard), content: const Text('hello world'))),
        child: MouseRegion(
            onEnter: (_) {
              // TODO: TRIGGER AVATAR TO ANIMATE
            },
            onExit: (_) {
              // TODO: TRIGGER AVATAR TO REVERSE ANIMATION
            },
            cursor: SystemMouseCursors.click,
            child: Stack(clipBehavior: Clip.none, children: [
              Container(
                  decoration: BoxDecoration(
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
                              color: false //info.id == MePlayer.inst.id
                                  ? GameplayStyles.colorPlayerMe
                                  : Colors.black,
                              height: 1.1)),
                      const Text('0 points',
                          style: TextStyle(fontSize: 12.6, height: 1, fontWeight: FontWeight.w700))
                    ],
                  )),
              Positioned(
                  top: -1,
                  right: 0,
                  child: AnimatedButtonBuilder(
                          child: info.avatar.doFitSize(height: 48, width: 48),
                          onTap: () {
                            // TODO: ADD OVERLAY FOR PLAYER INFO
                          },
                          decorators: [AnimatedButtonScaleDecorator(minSize: 1, maxSize: 1.2)])
                      .build()),
              Positioned(
                  top: 5,
                  left: 6,
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(fontSize: 15.4, fontWeight: FontWeight.w900),
                  )),
              if (info.isOwner == true)
                Positioned(
                    bottom: 0,
                    left: 4,
                    child:
                        Opacity(opacity: 0.7, child: GifManager.inst.misc('owner').builder.init()))
            ])));
  }
}
