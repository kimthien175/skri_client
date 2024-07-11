import 'dart:async';

import 'package:skribbl_client/models/game/state/game_state.dart';
import 'package:skribbl_client/models/game/message.dart';
import 'package:skribbl_client/models/game/player.dart';
import 'package:skribbl_client/pages/gameplay/widgets/main_content_footer/top_widget.dart';
import 'package:skribbl_client/utils/socket_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

abstract class Game extends GetxController {
  Game(
      {required this.currentRound,
      required this.rounds,
      required this.state,
      required this.playersByList,
      required this.roomCode,
      required this.settings}) {
    for (int i = 0; i < playersByList.length; i++) {
      var rxPlayer = playersByList[i];
      playersByMap[rxPlayer.id] = rxPlayer;
    }
  }
  static Game? _inst;
  static Game get inst => _inst!;
  static set inst(Game game) => _inst = game;

  String roomCode;
  String get inviteLink => '${html.window.location.host}/?$roomCode';

  copyLink() {
    Clipboard.setData(ClipboardData(text: Game.inst.inviteLink)).then(
        (value) => Game.inst.addMessage((color) => LinkCopiedMessage(backgroundColor: color)));
  }

  GameTimer remainingTime = GameTimer(0);
  RxInt rounds;
  RxInt currentRound;
  RxList<Player> playersByList;
  Map<String, Player> playersByMap = {};
  RxMap<String, dynamic> settings;

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

      case Message.playerChat:
        inst.messages.add(PlayerChatMessage(
            playerName: rawMessage['player_name'],
            chat: rawMessage['chat'],
            backgroundColor: color));
        break;

      case Message.playerWin:
        inst.messages.add(PlayerWinMessage(
            playerName: rawMessage['player_name'],
            score: rawMessage['score'],
            backgroundColor: color));
        break;

      case Message.playerDraw:
        inst.messages
            .add(PlayerDrawMessage(playerName: rawMessage['player_name'], backgroundColor: color));
        break;

      default:
        messages.add(Message(
            backgroundColor: messages.length % 2 == 0 ? Colors.red : const Color(0xffececec)));
        break;
    }
  }

  Rx<GameState> state;

  static void empty() => _inst = null;

  static bool get isEmpty => _inst == null;

  void leave() {
    state.value.clear();
    SocketIO.inst.socket.disconnect();

    // reset meplayer as well
    var me = MePlayer.inst;
    me.isOwner = false;
    me.points = 0;

    Get.back();
    Game.empty();
  }

  void chooseWord(String word) {
    Get.find<TopWidgetController>().controller.reverse();
    SocketIO.inst.socket.emit('choose_word', word);
  }
}

class GameTimer {
  GameTimer(int remainingTime) {
    seconds = remainingTime.obs;
  }
  late RxInt seconds;
  late Timer? timer;
  void start(int remainingTime, Function() onDone) {
    seconds.value = remainingTime;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds.value > 0) {
        seconds.value -= 1;
      } else {
        timer.cancel();
        onDone();
      }
    });
  }

  void stop() {
    seconds.value = 0;
    timer?.cancel();
  }
}
