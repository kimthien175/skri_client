library player_list;

export 'player_card.dart';

import 'package:skribbl_client/models/models.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/pages/pages.dart';

class PlayersListController extends GetxController {
  PlayersListController() {
    var players = Game.inst.playersByList;
    // init items controller
    for (int i = 0; i < players.length; i++) {
      Get.put(PlayerController(), tag: players[i].id);
    }

    // find winner
    for (int i = 0; i < players.length; i++) {
      if (players[i].points > players[winnerId].points) {
        winnerId = i;
      }
    }
    players[winnerId].avatarModel.winner = true;
  }

  // no need obs, because avatar controller have timer to re render periodly
  int winnerId = 0;

  void setWinner(int newWinnerId) {
    if (newWinnerId != winnerId) {
      var players = Game.inst.playersByList;
      // remove crown of old player
      players[winnerId].avatarModel.winner = false;
      // set crown of new player
      players[newWinnerId].avatarModel.winner = true;

      winnerId = newWinnerId;
    }
  }
}

class PlayersList extends StatelessWidget {
  const PlayersList({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        List<PlayerCard> children = [];
        var players = Game.inst.playersByList;
        for (int i = 0; i < players.length; i++) {
          children.add(PlayerCard(info: players[i], index: i));
        }
        return Column(children: children);
      });
}
