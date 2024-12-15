library game;

export 'private_game.dart';
export 'public_game.dart';
export 'package:skribbl_client/models/game/message.dart';
export 'package:skribbl_client/models/game/player.dart';
export 'state/game_state.dart';

import 'package:skribbl_client/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/utils.dart';
import 'package:skribbl_client/widgets/dialog/dialog.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'state/state.dart';

// TODO: lost connection and try to continue the game again
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

  RxInt rounds;
  RxInt currentRound;
  final RxList<Player> playersByList;
  final Map<String, Player> playersByMap = {};
  final RxMap<String, dynamic> settings;

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
        throw Exception('undefined message');
    }
  }

  Rx<GameState> state;

  static void empty() => _inst = null;

  static bool get isEmpty => _inst == null;

  void confirmLeave() async {
    var shouldPop = await GameDialog.cache(
        tag: 'gameplay-confirm-leave',
        builder: () => GameDialog(
            onQuit: (hide) async {
              await hide();
              return false;
            },
            title: const Text("You're leaving the game"),
            content: const Text('Are you sure?'),
            exitTap: true,
            buttons: const GameDialogButtons.row(children: [
              GameDialogButtonContainer(child: YesDialogButton()),
              GameDialogButtonContainer(child: NoDialogButton())
            ]))).showOnce();

    if (!shouldPop) return;

    //state.value.clear();
    SocketIO.inst.socket.disconnect();

    // reset meplayer as well
    var me = MePlayer.inst;
    me.isOwner = false;
    me.points = 0;

    Get.safelyToNamed('/');
    Game.empty();
  }
}

typedef GameStateInitCallback = GameState Function();
