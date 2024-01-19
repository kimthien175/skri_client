import 'dart:async';

import 'package:cd_mobile/models/game_play/message.dart';
import 'package:cd_mobile/models/game_play/player.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/utils/socket_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class Game extends GetxController {
  Game({
    required int remainingTime,
    required this.currentRound,
    required this.rounds,
    required this.status,
    required this.word,
    required this.players,
  }) {
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
  /// edit on this won't cause emiting to socketio
  RxList<Message> messages = List<Message>.empty().obs;
  /// add message only on client
  void addMessage(Map<String, dynamic> rawMessage) {
    switch (rawMessage['type']) {
      case 'hosting':
        messages.add(HostingMessage(
            playerName: rawMessage['player_name'],
            backgroundColor: messages.length % 2 == 0 ? Colors.red : Colors.blue));
        break;

      case 'drawing':
        messages.add(DrawingMessage(
            playerName: rawMessage['player_name'],
            backgroundColor: messages.length % 2 == 0 ? Colors.red : Colors.blue));
        break;

      case 'guess':
        messages.add(GuessMessage(
            playerName: rawMessage['player_name'],
            guess: rawMessage['guess'],
            backgroundColor: messages.length % 2 == 0 ? Colors.red : Colors.blue));
        break;

      case 'correct_guess':
        messages.add(CorrectGuessMessage(
            playerName: rawMessage['player_name'],
            backgroundColor: messages.length % 2 == 0 ? Colors.red : Colors.blue));
        break;

      default:
        messages.add(Message(backgroundColor: messages.length % 2 == 0 ? Colors.red : Colors.blue));
        break;
    }
  }

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

  static bool get isEmpty => _inst == null;

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
