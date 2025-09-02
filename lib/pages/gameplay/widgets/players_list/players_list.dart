library;

export 'player_card.dart';

import 'package:skribbl_client/models/models.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';

class PlayersListController extends GetxController {
  PlayersListController() {
    List<Player> list = [];
    Game.inst.playersByMap.forEach((id, player) {
      Get.put(PlayerController(), tag: player.id);
      _bubbleInsert(list, player);
    });

    this.list = list.obs;
  }

  late final RxList<Player> list;

  void _bubbleInsert(List<Player> list, Player newItem) {
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

  void add(Player player) {
    Get.put(PlayerController(), tag: player.id);
    _bubbleInsert(list, player);
  }

  void remove(String id) {
    list.removeWhere((player) => player.id == id);
    // remove PlayerController
    Get.delete<PlayerController>(tag: id);

    // remove info dialog controller
    OverlayController.deleteCache('card_info_$id');

    // remove report dialog controller
    OverlayController.deleteCache('report $id');
  }

  /// since player with `id` get plus score, then find new position to swap
  void sortFrom(String id) {
    var index = list.indexWhere((player) => player.id == id);
    if (index == -1) return;
    var score = list[index].score;
    for (var i = index - 1; i >= 0; i--) {
      if (list[i].score >= score) {
        if (i + 1 == index) return;
        list.insert(i, list.removeAt(index));
        return;
      }
    }

    // swap to top
    if (index == 0) return;
    list.insert(0, list.removeAt(index));
    list.refresh();
  }
}

class PlayersList extends StatelessWidget {
  const PlayersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var cards = <PlayerCard>[];
      var list = Get.find<PlayersListController>().list;
      for (var i = 0; i < list.length; i++) {
        cards.add(PlayerCard(info: list[i], index: i));
      }
      return Column(children: cards);
    });
  }
}
