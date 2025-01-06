library game;

export 'private_game.dart';

export 'package:skribbl_client/models/game/message.dart';
export 'package:skribbl_client/models/game/player.dart';
export 'state/game_state.dart';

import 'dart:collection';

import 'package:skribbl_client/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/utils.dart';
import 'package:skribbl_client/widgets/dialog/dialog.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../../widgets/widgets.dart';
import 'state/state.dart';

// TODO: lost connection and try to continue the game again
class Game extends GetxController {
  Game({required this.data}) {
    state = GameState.fromJSON(data['states'][0]).obs;

    futureStates = Queue<GameState>();
    for (var jsonState in data['future_states']) {
      futureStates.add(GameState.fromJSON(jsonState));
    }

    playersByList = Player.listFromJSON(data['players']).obs;
    for (int i = 0; i < playersByList.length; i++) {
      var rxPlayer = playersByList[i];
      playersByMap[rxPlayer.id] = rxPlayer;
    }

    settings = (data['settings'] as Map<String, dynamic>).obs;

    messages = Message.listFromJSON(data['messages']).obs;

    currentRound = (data['current_round'] as int).obs;
  }
  static Game? _inst;
  static Game get inst => _inst!;
  static set inst(Game game) => _inst = game;

  final Map<String, dynamic> data;

  String get roomCode => data['code'];
  Map<String, dynamic> get system => data['system'];
  List<dynamic> get roundWhiteList => data['round_white_list'];
  late final RxInt currentRound;

  String get inviteLink => '${html.window.location.host}/?$roomCode';

  copyLink() {
    Clipboard.setData(ClipboardData(text: Game.inst.inviteLink)).then(
        (value) => Game.inst.addMessage((color) => LinkCopiedMessage(backgroundColor: color)));
  }

  late final RxList<Player> playersByList;
  final Map<String, Player> playersByMap = {};
  late final RxMap<String, dynamic> settings;

  /// edit on this won't cause emiting to socketio
  late final RxList<Message> messages;

  void addMessage(Message Function(Color color) callback) {
    messages.add(callback(messages.length % 2 == 0 ? Colors.white : const Color(0xffececec)));
  }

  late Rx<GameState> state;
  late Queue<GameState> futureStates;

  static bool get isEmpty => _inst == null;

  void confirmLeave() {
    var dialog = OverlayController.cache(
        tag: 'confirm_leave',
        builder: () => GameDialog(
            title: Text("dialog_title_confirm_leave".tr),
            content: Text('dialog_content_confirm_leave'.tr),
            buttons: const RowRenderObjectWidget(
                children: [GameDialogButton.yes(), GameDialogButton.no()])));

    dialog.show().then((value) {
      if (value) leave();
    });
  }

  static leave() {
    //state.value.clear();
    SocketIO.inst.socket.disconnect();

    // reset meplayer as well
    MePlayer.inst.points = 0;

    Get.safelyToNamed('/');
    _inst = null;
  }

  // factory Game.fromJSON(dynamic data) {
  //   var futureStates = Queue<GameState>();
  //   for (var state in data) {
  //     futureStates.add(GameState.fromJSON(data));
  //   }
  //   return Game(
  //       data: data,
  //       playersByList: Player.listFromJSON(data['players']).obs,
  //       state: GameState.fromJSON(data['state']).obs,
  //       futureState: Qu);
  // }
}

typedef GameStateInitCallback = GameState Function();
