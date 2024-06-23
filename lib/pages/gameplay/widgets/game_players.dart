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
    var players = List<Player>.generate(
        5,
        (index) => Player(
            id: 'id',
            name: 'wrath',
            isOwner: false,
            avatar: AvatarModel.init(0, 0, 0).builder.init()));
    List<PlayerCard> list = [];

    int maxPointPlayerIndex = 0;

    for (int i = 0; i < players.length; i++) {
      if (players[i].points > players[maxPointPlayerIndex].points) {
        maxPointPlayerIndex = i;
      }
      list.add(PlayerCard(index: i, info: players[i]));
    }

    list[maxPointPlayerIndex].info.avatar.model.winner = true;
    return Column(
      children: list,
    );
  }
}

class PlayerCard extends StatelessWidget {
  const PlayerCard({required this.info, required this.index, super.key});
  final Player info;
  final int index;

  static const double avatarMaxScale = 1.15;
  @override
  Widget build(BuildContext context) {
    var lastIndex = 4;
    var avatarScaleDecorator = AnimatedButtonScaleDecorator(minSize: 1 / avatarMaxScale);
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
                      borderRadius: index == 0
                          ? (index == lastIndex
                              ? BorderRadius.circular(3)
                              : const BorderRadiusDirectional.vertical(top: Radius.circular(3)))
                          : (index == lastIndex
                              ? const BorderRadiusDirectional.vertical(bottom: Radius.circular(3))
                              : const BorderRadius.all(Radius.zero)),
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
                  top: -1 - 48 * (avatarMaxScale - 1) / 2,
                  right: -48 * (avatarMaxScale - 1) / 2,
                  child: AnimatedButtonBuilder(
                      child: info.avatar
                          .doFitSize(height: 48 * avatarMaxScale, width: 48 * avatarMaxScale),
                      onTap: () {
                        // TODO: ADD OVERLAY FOR PLAYER INFO
                      },
                      decorators: [avatarScaleDecorator]).build()),
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
