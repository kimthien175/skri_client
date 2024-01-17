import 'package:cd_mobile/models/game_play/player.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/utils/socket_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class Game<GAME_TYPE extends Game<GAME_TYPE>> {
  Game(this.players);
  static Game? _inst;
  static Game get inst => _inst!;

  List<Player> players;

  static void initPrivateRoom() {
    _inst = PrivateGame.init();
  }

  static empty() {
    _inst = null;
  }
}

class PrivateGame extends Game<PrivateGame> {
  PrivateGame(super.players);
  static PrivateGame init() {
    // set up MePlayer
    var me = MePlayer.inst;
    me.isOwner = true;
    me.name = me.name.trim();

    return PrivateGame([me]).requestRoom();
  }

  dynamic requestedRoomInfo= {};

  Map<String, dynamic> settings = {};

  PrivateGame requestRoom() {
    var inst = SocketIO.inst;

    inst.eventHandlers.onConnect = () {
      inst.socket.emitWithAck('init_room', MePlayer.inst.name, ack: (requestedRoomResult) {
        if (requestedRoomResult['error'] != null) {
          Get.find<HomeController>().isLoading.value = false;
          showDialog(
              context: Get.context!,
              builder: (context) => AlertDialog(
                  title: const Text('Can not create private room right now'),
                  content: Text(requestedRoomResult['error'].toString())));
        } else {
          var result = requestedRoomResult['ok'];
          if (MePlayer.inst.name.isEmpty) {
            MePlayer.inst.name = result['ownerName'];
          }

          requestedRoomInfo = result;

          Get.toNamed('/gameplay');

          Get.find<HomeController>().isLoading.value = false;

          inst.eventHandlers.onConnect = () {};
        }
      });
    };

    inst.socket.connect();

    return this;
  }
}
