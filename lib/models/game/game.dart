import 'dart:async';

import 'package:cd_mobile/models/game/message.dart';
import 'package:cd_mobile/models/game/player.dart';
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
      required this.playersByList,
      required this.roomCode}) {
    this.remainingTime = GameTimer(remainingTime);
    for (int i = 0; i < playersByList.length; i++) {
      var rxPlayer = playersByList[i];
      playersByMap[rxPlayer.id] = rxPlayer;
    }
  }
  static Game? _inst;
  static Game get inst => _inst!;
  static set inst(Game game) => _inst = game;

  late GameTimer remainingTime;
  RxInt rounds;
  RxInt currentRound;
  RxString word;
  RxList<Player> playersByList;
  Map<String, Player> playersByMap = {};
  String roomCode;

  /// edit on this won't cause emiting to socketio
  RxList<Message> messages = List<Message>.empty().obs;

  void addMessage(Message Function(Color color) callback) {
    messages.add(callback(messages.length % 2 == 0 ? Colors.white : const Color(0xffececec)));
  }

  /// add message only on client
  void addMessageByRaw(Map<String, dynamic> rawMessage) {
    Color color = messages.length % 2 == 0 ? Colors.white : const Color(0xffececec);
    switch (rawMessage['type']) {
      case Message.newHost:
        messages.add(NewHostMessage(playerName: rawMessage['player_name'], backgroundColor: color));
        break;

      case Message.playerJoin:
        messages
            .add(PlayerJoinMessage(playerName: rawMessage['player_name'], backgroundColor: color));
        break;

      case Message.playerLeave:
        inst.messages
            .add(PlayerLeaveMessage(playerName: rawMessage['player_name'], backgroundColor: color));
        break;

      case Message.playerGuess:
        inst.messages.add(PlayerGuessMessage(
            playerName: rawMessage['player_name'],
            guess: rawMessage['guess'],
            backgroundColor: color));
        break;

      case Message.playerWin:
        inst.messages.add(PlayerWinMessage(
            playerName: rawMessage['player_name'],
            score: rawMessage['score'],
            backgroundColor: color));
        break;
      
      case Message.playerDraw:
        inst.messages.add(PlayerDrawMessage(playerName: rawMessage['player_name'], backgroundColor: color));
        break;

      default:
        messages.add(Message(
            backgroundColor: messages.length % 2 == 0 ? Colors.red : const Color(0xffececec)));
        break;
    }
  }

  Rx<String> status;

  static void empty() => _inst = null;

  static bool get isEmpty => _inst == null;

  void leave() {
    SocketIO.inst.socket.disconnect();

    // reset meplayer as well
    var me = MePlayer.inst;
    me.isOwner = false;
    me.points = 0;

    Get.back();
    Game.empty();
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
