library player_list;

export 'player_card.dart';

import 'package:skribbl_client/models/models.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/pages/pages.dart';

class PlayersListController extends GetxController {
  PlayersListController() {
    players = List<Player>.generate(
        5,
        (index) => Player(
            id: 'id',
            name: 'wrath',
            isOwner: false,
            avatar: AvatarModel.init(0, 0, 0).builder.init()));

    // init items controller
    for (int i = 0; i < players.length; i++) {
      Get.put(PlayerController(), tag: i.toString());
    }

    // find winner
    for (int i = 0; i < players.length; i++) {
      if (players[i].points > players[winnerId].points) {
        winnerId = i;
      }
    }
    players[winnerId].avatar.model.winner = true;
  }

  // TODO: dump player list, need changing when apply proper game logic
  late final List<Player> players;

  // no need obs, because avatar controller have timer to re render periodly
  int winnerId = 0;

  void setWinner(int newWinnerId) {
    if (newWinnerId != winnerId) {
      // remove crown of old player
      players[winnerId].avatar.model.winner = false;
      // set crown of new player
      players[newWinnerId].avatar.model.winner = true;

      winnerId = newWinnerId;
    }
  }
}

class PlayersList extends StatelessWidget {
  const PlayersList({super.key});

  @override
  Widget build(BuildContext context) {
    List<PlayerCard> children = [];
    var players = Get.find<PlayersListController>().players;
    for (int i = 0; i < players.length; i++) {
      children.add(PlayerCard(info: players[i], index: i));
    }

    return Column(children: children);
  }
}
