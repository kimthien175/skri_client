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

  /// add message only on client
  void addMessage(Map<String, dynamic> rawMessage) {
    switch (rawMessage['type']) {
      case Message.newHost:
        messages.add(NewHostMessage(
            playerName: rawMessage['player_name'],
            backgroundColor: messages.length % 2 == 0 ? Colors.white : const Color(0xffececec)));
        break;

      case Message.playerJoin:
        messages.add(PlayerJoinMessage(
            playerName: rawMessage['player_name'],
            backgroundColor: messages.length % 2 == 0 ? Colors.white : const Color(0xffececec)));
        break;

      case Message.playerLeave:
        inst.messages.add(PlayerLeaveMessage(
            playerName: rawMessage['player_name'],
            backgroundColor: messages.length % 2 == 0 ? Colors.white : const Color(0xffececec)));
        break;

      case Message.playerGuess:
        inst.messages.add(PlayerGuessMessage(
            playerName: rawMessage['player_name'],
            guess: rawMessage['guess'],
            backgroundColor: messages.length % 2 == 0 ? Colors.white : const Color(0xffececec)));
        break;

      // case Message.drawing:
      //   var playerName = playersByMap[rawMessage['player_id']]!.name;
      //   messages.add(DrawingMessage(
      //       playerName: playerName,
      //       backgroundColor: messages.length % 2 == 0 ? Colors.white : const Color(0xffececec)));
      //   break;



      // case Message.correctGuess:
      //   var playerName = playersByMap[rawMessage['player_id']]!.name;
      //   messages.add(CorrectGuessMessage(
      //       playerName: playerName,
      //       backgroundColor: messages.length % 2 == 0 ? Colors.white : const Color(0xffececec)));
      //   break;



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
  // static void registerRoomErrorHandlerAtGameplayPage(String title) {

  //     // at GameplayPage, try to reconnect
  //     if (Get.currentRoute != '/') {
  //       if (isDialogShown) return;

  //       var gameplayController = Get.find<GameplayController>();

  //       // set loading
  //       gameplayController.isLoading.value = true;

  //       // stop loading when reconnect sucessfully
  //       inst.eventHandlers.onReconnect = (_) {
  //         gameplayController.isLoading.value = false;
  //         if (isDialogShown) {
  //           Get.back();
  //           isDialogShown = false;
  //         }

  //         inst.eventHandlers.onReconnect = SessionEventHandlers.emptyOnReconnect;
  //       };

  //       Get.defaultDialog(
  //         content: PopScope(canPop: false, child: Text('gameplay_connection_error_message'.tr)),
  //         barrierDismissible: false,
  //         title: 'connection_error'.tr,
  //         textCancel: 'No'.tr,
  //         onCancel: () {
  //           Get.back();
  //           Game.inst.leave();
  //         },
  //       );
  //       isDialogShown = true;

  //       return;
  //     }

  //     // at homepage trying to create room
  //     inst.socket.disconnect();
  //     Get.find<HomeController>().isLoading.value = false;
  //     showDialog(
  //         context: Get.context!,
  //         builder: (context) => AlertDialog(title: Text(title), content: Text(data.toString())));
  //   };
  // }
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
