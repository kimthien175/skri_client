import 'dart:async';

import 'package:cd_mobile/models/game_play/message.dart';
import 'package:cd_mobile/models/game_play/player.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/utils/socket_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class Game extends GetxController {
  Game(
      {required int remainingTime,
      required this.currentRound,
      required this.rounds,
      required this.status,
      required this.word,
      required this.players,
      required this.messages}) {
    this.remainingTime = GameTimer(remainingTime);
  }
  static Game? _inst;
  static Game get inst => _inst!;
  static set inst(Game game) => _inst = game;

  late GameTimer remainingTime;
  RxInt rounds;
  RxInt currentRound;
  RxString word;
  RxList<Player> players;
  RxList<Message> messages;
  Rx<String> status;

  // static void initPrivateRoomAsOwner() {
  //   // set up MePlayer
  //   var me = MePlayer.inst;
  //   me.isOwner = true;
  //   me.name = me.name.trim();

  //   _inst = OwnedPrivateGame.init();//([me]).requestInitRoom();
  // }

  // static void joinPrivateRoomAsParticipant(String roomCode)async {
  //   var me = MePlayer.inst;
  //   me.name = me.name.trim();

  //   _inst = await PrivateGame.joinRoom(roomCode);
  // }

  // static void joinPrivateGame(String roomCode) async {
  //   var me = MePlayer.inst;
  //   me.name = me.name.trim();

  //   _inst = await PrivateGame.join(roomCode);
  // }

  // static void joinPublicGame(){
  //   _inst = PublicGame.init();
  // }

  static empty() {
    _inst = null;
  }

  static void registerRoomErrorHandler(String title) {
    var inst = SocketIO.inst;
    inst.eventHandlers.onConnectError = (data) {
      inst.socket.disconnect();
      Get.find<HomeController>().isLoading.value = false;
      showDialog(
          context: Get.context!,
          builder: (context) => AlertDialog(title: Text(title), content: Text(data.toString())));

      inst.eventHandlers.onConnectError = SessionEventHandlers.emptyOnConnectError;
    };
  }
}

class GameTimer {
  GameTimer(int remainingTime) {
    seconds = remainingTime.obs;
    if (seconds > 0) {
      // start counting down
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (seconds.value > 0) {
          seconds.value -= 1;
        } else {
          timer.cancel();
        }
      });
    }
  }
  late RxInt seconds;
  late Timer? timer;
}
