import 'dart:async';

import 'package:cd_mobile/models/game_play/message.dart';
import 'package:cd_mobile/models/game_play/player.dart';
import 'package:cd_mobile/pages/gameplay/gameplay.dart';
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

  /// add message only on client
  void addMessage(Map<String, dynamic> rawMessage) {
    switch (rawMessage['type']) {
      case 'hosting':
        var playerName = playersByMap[rawMessage['player_id']]!.name;
        messages.add(HostingMessage(
            playerName: playerName,
            backgroundColor: messages.length % 2 == 0 ? Colors.white : const Color(0xffececec)));
        break;

      case 'drawing':
        var playerName = playersByMap[rawMessage['player_id']]!.name;
        messages.add(DrawingMessage(
            playerName: playerName,
            backgroundColor: messages.length % 2 == 0 ? Colors.white : const Color(0xffececec)));
        break;

      case 'guess':
        var playerName = playersByMap[rawMessage['player_id']]!.name;
        messages.add(GuessMessage(
            playerName: playerName,
            guess: rawMessage['guess'],
            backgroundColor: messages.length % 2 == 0 ? Colors.white : const Color(0xffececec)));
        break;

      case 'correct_guess':
        var playerName = playersByMap[rawMessage['player_id']]!.name;
        messages.add(CorrectGuessMessage(
            playerName: playerName,
            backgroundColor: messages.length % 2 == 0 ? Colors.white : const Color(0xffececec)));
        break;

      case 'new_player':
        var playerName = playersByMap[rawMessage['player_id']]!.name;
        messages.add(NewPlayerMessage(
            playerName: playerName,
            backgroundColor: messages.length % 2 == 0 ? Colors.white : const Color(0xffececec)));
        break;

      default:
        messages.add(Message(
            backgroundColor: messages.length % 2 == 0 ? Colors.red : const Color(0xffececec)));
        break;
    }
  }

  Rx<String> status;

  static empty() {
    _inst = null;
  }

  static bool get isEmpty => _inst == null;

  static bool isDialogShown = false;

  static void registerRoomErrorHandler(String title) {
    var inst = SocketIO.inst;
    inst.eventHandlers.onConnectError = (data) {
      // at GameplayPage, try to reconnect
      if (Get.currentRoute != '/') {
        if (isDialogShown) return;

        var gameplayController = Get.find<GameplayController>();

        // set loading
        gameplayController.isLoading.value = true;

        // stop loading when reconnect sucessfully
        inst.eventHandlers.onReconnect = (_) {
          gameplayController.isLoading.value = false;
          if (isDialogShown) {
            Get.back();
            isDialogShown = false;
          }

          inst.eventHandlers.onReconnect = SessionEventHandlers.emptyOnReconnect;
        };

        Get.defaultDialog(
          content: PopScope(canPop: false, child: Text('gameplay_connection_error_message'.tr)),
          barrierDismissible: false,
          title: 'connection_error'.tr,
          textCancel: 'No'.tr,
          onCancel: () {
            Get.back();
            Get.back();
            GameplayPage.onBack();
          },
        );
        isDialogShown = true;

        return;
      }

      // at homepage trying to create room
      inst.socket.disconnect();
      Get.find<HomeController>().isLoading.value = false;
      showDialog(
          context: Get.context!,
          builder: (context) => AlertDialog(title: Text(title), content: Text(data.toString())));
    };
  }

  bool onLeaving = false;
  void leave(){
    // if meplayer are the only player on the list, mean meplayer is owner
    if (playersByList.length ==1){
      // emit to server to delete the room
      SocketIO.inst.socket.emitWithAck('delete_room',roomCode);
      GameplayPage.onBack();
      return;
    }

    if (MePlayer.inst.isOwner){
      // pass owner ship to the near player
      // emit to pass owener ship
      SocketIO.inst.socket.emitWithAck('pass_owner_ship', 'ok', ack:(_){
        GameplayPage.onBack();
      });
      return;
    }

    // room still has players and meplayer is not room owner
    GameplayPage.onBack();
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
