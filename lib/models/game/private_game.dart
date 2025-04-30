import 'package:skribbl_client/models/game/game.dart';

import 'package:skribbl_client/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/utils.dart';

import '../../widgets/widgets.dart';

class PrivateGame extends Game {
  static load(Map<String, dynamic> roomResult) {
    if (roomResult['success']) {
      var data = roomResult['data'];

      var me = MePlayer.inst;

      //#region set up player
      // set room owner name if empty
      if (me.name.isEmpty) {
        me.name = data['player']['name'];
      }
      me.id = data['player']['id'];
      //#endregion

      Game.inst = PrivateGame._internal(data: data['room']);

//#region edit local storage for rejoin ticket
      var homeController = Get.find<HomeController>();

      if (homeController.hasCode && homeController.isPrivateRoomCodeValid) {
        var kickMap = Storage.data['kick'];
        if (kickMap != null) {
          var ticket = kickMap[homeController.privateRoomCode];
          if (ticket != null) {
            ticket['used_by'] = Game.inst.hashCode;
            Storage.set(['kick', homeController.privateRoomCode], ticket);
          }
        }
      }
//#endregion

      Get.to(() => const GameplayPage(),
          binding: GameplayBinding(), transition: Transition.noTransition);

      // save metadata to local storage
      Storage.set(['system'], Game.inst.data['system']);
    } else {
      SocketIO.inst.socket.disconnect();

      GameDialog.error(content: Center(child: Text(roomResult['data'].toString()))).show();
    }

    LoadingOverlay.inst.hide();
  }

  PrivateGame._internal({required super.data}) {
    hostPlayerId = (data['host_player_id'] as String).obs;
  }

  static Future<void> setupTesting() async {
    Map<String, dynamic> data = {
      "code": "dlrc",
      "host_player_id": "fDmSIumozqWBdX87AAAE",
      "players": [
        {
          "name": "worry",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12},
          "id": "fDmSIumozqWBdX87AAAE"
        }
      ],
      "messages": [
        {
          "type": "new_host",
          "timestamp": "2025-04-25T14:16:57.658Z",
          "player_id": "fDmSIumozqWBdX87AAAE",
          "player_name": "worry"
        }
      ],
      "options": {
        "players": {"min": 2, "max": 20},
        "language": ["en_US", "vi_VN"],
        "rounds": {"min": 2, "max": 10},
        "word_mode": ["Normal", "Hidden", "Combination"],
        "word_count": {"min": 1, "max": 5},
        "hints": {"min": 0, "max": 5},
        "custom_words_rules": {
          "min_words": 10,
          "min_char_per_word": 1,
          "max_char_per_word": 32,
          "max_char": 20000
        },
        "draw_time": [15, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120, 150, 180, 210, 240]
      },
      "system": {"pick_word_time": 15, "kick_interval": 30},
      "settings": {
        "players": 8,
        "language": "en_US",
        "rounds": 3,
        "word_mode": "Normal",
        "word_count": 3,
        "hints": 2,
        "draw_time": 80
      },
      "round_white_list": ["fDmSIumozqWBdX87AAAE"],
      "current_round": 1,
      "old_states": [],
      "_id": "680b9959c4a0f77046faa934",
      //
      "status": {
        "current_state_id": "680b9959c4a0f77046faa933",
        "command": "end",
        "date": DateTime.now().toUtc().toIso8601String(),
        "next_state_id": "680cd9b9b34194c2298d16a4"
      },
      "henceforth_states": {
        "680b9959c4a0f77046faa933": {
          "type": "pick_word",
          "id": "680b9959c4a0f77046faa933",
          "round_notify": null,
          'player_id': "fDmSIumozqWBdX87AAAE",
          "words": ["ourselves", "choose", "for"]
        } as dynamic,
        "680cd9b9b34194c2298d16a4": {
          "type": "draw",
          "id": "680cd9b9b34194c2298d16a4",
          "player_id": "fDmSIumozqWBdX87AAA",
          "word": "the fish"
        } as dynamic
      }
    };

    MePlayer.inst = MePlayer.fromJSON(data['players'][0]);
    Game.inst = PrivateGame._internal(data: data);
  }

  static trigger() {
    Map<String, dynamic> mockData = <String, dynamic>{
      "status": {
        "current_state_id": "680b9959c4a0f77046faa933",
        "command": "end",
        "date": DateTime.now().toUtc().toIso8601String(),
        "next_state_id": "680cd9b9b34194c2298d16a4"
      },
      "henceforth_states": {
        "680cd9b9b34194c2298d16a4": {
          "type": "pick_word",
          "id": "680cd9b9b34194c2298d16a4",
          "player_id": "lQiMMk8s6BMWIktYAAAK",
          "words": ["remain", "club", "map"],
          "round_notify": 1
        },
        "680cd9b9b34194c2298d16a5": {
          "type": "pick_word",
          "id": "680cd9b9b34194c2298d16a5",
          "player_id": "QyN_hx0JNrQRLyIHAAAH",
          "words": ["ourselves", "choose", "for"]
        }
      }
    };

    Game.inst.receiveStatusAndStates(mockData);
  }

  late RxString hostPlayerId;

  Map<String, dynamic> get options => data['options'];

  void changeSettings(String key, dynamic value) {
    settings[key] = value;
    SocketIO.inst.socket.emit('change_settings', {'key': key, 'value': value});
  }

  /// use for join and host starting connecting to server
  /// disconnect immediately and hide loading overlay, show dialog notifying error
  static void _connect(SocketCallback callback) {
    LoadingOverlay.inst.show();

    var socket = SocketIO.inst.socket;

    socket.once('connect_error', (data) {
      SocketIO.inst.socket.disconnect();

      OverlayController.cache(
              tag: 'connect_error_dialog',
              builder: () => GameDialog.error(
                  onQuit: (hide) async {
                    await hide();

                    if (Get.currentRoute != '/') {
                      Game.leave();
                    }
                    return true;
                  },
                  content: Center(
                      child:
                          Builder(builder: (_) => Text('dialog_content_no_server_connection'.tr)))))
          .show();

      LoadingOverlay.inst.hide();
    });

    socket.once('connect', callback);

    socket.connect();
  }

  static Future<void> host() async {
    _connect((data) {
      SocketIO.inst.socket.emitWithAck(
          'init_private_room', {'player': MePlayer.inst.toJSON(), 'lang': Get.locale!.toString()},
          ack: PrivateGame.load);
    });
  }

  static void join(String code) {
    Map<String, dynamic> requestPackage = {
      'player': MePlayer.inst.toJSON(),
      'code': code,
      'lang': Get.locale!.toString()
    };

    var banList = Storage.data['ban'];
    if (banList is List && banList.contains(code)) {
      var dialog = OverlayController.cache(
          tag: 'join_but_get_banned',
          builder: () => GameDialog.error(
              content: Center(child: Text('dialog_content_join_but_get_banned'.tr))));
      if (!dialog.isShowing) {
        dialog.show();
      }
      return;
    }

    var kickMap = Storage.data['kick'];
    if (kickMap != null) {
      var ticket = kickMap[code];
      if (ticket != null) {
        // check kick interval
        var system = Storage.data['system'];
        if (system != null) {
          var kickInterval = system['kick_interval'];
          if (kickInterval is int) {
            var kickDate = DateTime.tryParse(kickMap[code]['date']);
            if (kickDate != null) {
              if ((DateTime.now() - kickDate).inSeconds < kickInterval) {
                // still in kick interval
                var dialog = OverlayController.cache(
                    tag: 'kick interval',
                    builder: () => GameDialog.error(
                        content: Builder(
                            builder: (_) =>
                                Center(child: Text('dialog_content_kick_countdown'.tr)))));
                if (!dialog.isShowing) {
                  dialog.show();
                }
                return;
              } else {
                // modify request package for ticket
                if (ticket['room_id'] is String && ticket['ticket_id'] is String) {
                  requestPackage['room_id'] = ticket['room_id'];
                  requestPackage['ticket_id'] = ticket['ticket_id'];
                }
              }
            }
          }
        }
      }
    }

    _connect((data) {
      // emit join private room
      SocketIO.inst.socket.emitWithAck('join_private_room', requestPackage, ack: PrivateGame.load);
    });

    // inst.eventHandlers.onConnect = (_) {
    //   inst.socket.emitWithAck('join_private_room', {
    //     'player': MePlayer.inst.toJSON(),
    //     'code': roomCode,
    //     'lang': Get.locale!.toString()
    //   }, ack: (requestedJoiningRoomResult) {
    //     if (requestedJoiningRoomResult['success']) {
    //       var roomAndNewPlayer = requestedJoiningRoomResult['data'];

    //       // modify MePlayer

    //       var me = MePlayer.inst;
    //       if (me.name.isEmpty) {
    //         me.name = roomAndNewPlayer['player']['name'];
    //       }
    //       me.id = roomAndNewPlayer['player']['id'];

    //       var room = roomAndNewPlayer['room'];

    //       // currentRound
    //       int currentRound = 1;
    //       if (room['currentRound'] != null) {
    //         currentRound = room['currentRound'];
    //       }

    //       // rounds
    //       int rounds = room['settings']['rounds'];

    //       // state
    //       GameState state = GameState.fromJSON(room['state']);

    //       // players
    //       List<dynamic> rawPlayers = room['players'];
    //       List<Player> players = [];
    //       for (dynamic rawPlayer in rawPlayers) {
    //         if (rawPlayer['id'] == me.id) {
    //           players.add(MePlayer.inst);
    //         } else {
    //           players.add(Player.fromJSON(rawPlayer));
    //         }
    //       }

    //       String roomCode = room['code'];

    //       Game.inst = PrivateGame._internal(
    //           currentRound: currentRound.obs,
    //           rounds: rounds.obs,
    //           state: state.obs,
    //           playersByList: players.obs,
    //           roomCode: roomCode,
    //           options: room['options'],
    //           settings: (room['settings'] as Map<String, dynamic>).obs);

    //       Get.to(() => const GameplayPage(),
    //           binding: GameplayBinding(), transition: Transition.noTransition);

    //       for (dynamic rawMessage in room['messages']) {
    //         Game.inst.addMessageByRaw(rawMessage);
    //       }
    //     } else {
    //       inst.socket.disconnect();
    //       showDialog(
    //           context: Get.context!,
    //           builder: (context) => AlertDialog(
    //               title: Text('wrong_private_room_code'.tr),
    //               content: Text(requestedJoiningRoomResult['data'].toString())));
    //     }

    //     LoadingOverlay.inst.hide();
    //     //   inst.eventHandlers.onConnect = SessionEventHandlers.emptyOnConnect;
    //   });
    // };
  }

  static bool _isSendingStartGameRequest = false;
  void startGame() {
    if (playersByList.length < (Game.inst as PrivateGame).options['players']['min']) {
      addMessage((Color color) => RequiredMinimumPlayersToStartMessage(backgroundColor: color));
      return;
    }
    // gather settings, settings from dropdown and check button is saved in settings already
    // now have left only the custom words
    if (Get.find<GameSettingsController>().formKey.currentState!.validate()) {
      // do once
      if (_isSendingStartGameRequest) return;
      _isSendingStartGameRequest = true;
      SocketIO.inst.socket.emitWithAck('start_private_game', Game.inst.settings, ack: (res) {
        _isSendingStartGameRequest = false;
        if (!res['success']) {
          var dialog = OverlayController.cache(
              tag: 'start_private_game_errror',
              builder: () =>
                  GameDialog.error(content: Center(child: Text(res['reason'].toString()))));
          if (!dialog.isShowing) {
            dialog.show();
          }
        }
      });
    }
  }

  // Map<String, dynamic> getDifferentSettingsFromDefault() {
  //   Map<String, dynamic> result = {};
  //   var defaultSettings = succeededCreatedRoomData['settings']['default'];
  //   for (String key in settings.keys) {
  //     if (settings[key] != defaultSettings[key]) result[key] = settings[key];
  //   }
  //   return result;
  // }
}
