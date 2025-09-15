import 'package:skribbl_client/models/game/game.dart';

import 'package:skribbl_client/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/utils.dart';

import '../../widgets/widgets.dart';

class PrivateGame extends Game {
  static void load(Map<String, dynamic> roomResult) {
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

      Get.to(() => const GameplayPage(), transition: Transition.noTransition);

      // save metadata to local storage
      Storage.set(['system'], Game.inst.data['system']);
    } else {
      SocketIO.inst.socket.disconnect();

      GameDialog.error(content: Center(child: Text(roomResult['reason'].toString()))).show();
    }

    LoadingOverlay.inst.hide();
  }

  @override
  void reload(Map<String, dynamic> room) {
    hostPlayerId.value = room['host_player_id'];
    super.reload(room);
  }

  PrivateGame._internal({required super.data}) {
    hostPlayerId = (data['host_player_id'] as String).obs;
  }

  static Future<void> setupTesting() async {
    Map<String, dynamic> data = {
      "code": "dlrc",
      "host_player_id": "fDmSIumozqWBdX87AAAE",
      "players": {
        "fDmSIumozqWBdX87AAAE": {
          "name": "worry",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12},
          "id": "fDmSIumozqWBdX87AAAE"
        },
        "WWEAmL4U": {
          "id": "WWEAmL4U",
          "name": "Flcpmizdv",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "iBnJ6uBN": {
          "id": "iBnJ6uBN",
          "name": "D Myfqwslktfmrwhfhou",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "04lxSxZa": {
          "id": "04lxSxZa",
          "name": "Sntxufnvx",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "StzosDkc": {
          "id": "StzosDkc",
          "name": "Tkizn",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "ENrBp2BG": {
          "id": "ENrBp2BG",
          "name": "Assyahsierlpe",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "xHfT4tvh": {
          "id": "xHfT4tvh",
          "name": "Hxjcmjonpmem",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "8X1u11Wq": {
          "id": "8X1u11Wq",
          "name": "Qntkfz Bflsgrf",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "uZoEeKMu": {
          "id": "uZoEeKMu",
          "name": "Gdctykvlsibolu",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "ViWToJfv": {
          "id": "ViWToJfv",
          "name": "Ovnjr",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "5YX6ryba": {
          "id": "5YX6ryba",
          "name": "Tqeiuhrrgtroy O",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "PSS6IMpo": {
          "id": "PSS6IMpo",
          "name": "Ameyytha",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "1GdAjnIA": {
          "id": "1GdAjnIA",
          "name": "Zrhw",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "i0ocogCF": {
          "id": "i0ocogCF",
          "name": "Jjlgarnbwf",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "c9wOaQfP": {
          "id": "c9wOaQfP",
          "name": "Tyvd Ahceldjua",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "cfQZxYk4": {
          "id": "cfQZxYk4",
          "name": "Szmwxdzds",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "rneIFu8k": {
          "id": "rneIFu8k",
          "name": "Kegqhalv",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "BChA55fj": {
          "id": "BChA55fj",
          "name": "Mbw",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "e71C9iWw": {
          "id": "e71C9iWw",
          "name": "Ori  Zoftai",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "lvEf8oRL": {
          "id": "lvEf8oRL",
          "name": "Ydldaueiefyxrjcmv",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "HHl2q4QN": {
          "id": "HHl2q4QN",
          "name": "Fsslulvhqzdhapal",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "QKyqXknH": {
          "id": "QKyqXknH",
          "name": "Faeavp",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "vfnTmOpu": {
          "id": "vfnTmOpu",
          "name": "Qqn S",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "QX6MHu2w": {
          "id": "QX6MHu2w",
          "name": "Gaizxfxwgscucydqp",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "2uqWGm0r": {
          "id": "2uqWGm0r",
          "name": "Zake",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "KHnGbLQd": {
          "id": "KHnGbLQd",
          "name": "Ks Shtpmm",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "ER3emqQc": {
          "id": "ER3emqQc",
          "name": "Ymztrwlrwfsbl Exfroj",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "29juyknw": {
          "id": "29juyknw",
          "name": "Vuaefwnclfyxagt",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "VvFoDY11": {
          "id": "VvFoDY11",
          "name": "Jrq ",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "WgRuBj1z": {
          "id": "WgRuBj1z",
          "name": "Qnrsiywg Fiuxthkt",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "AwROhV4k": {
          "id": "AwROhV4k",
          "name": "Aasmcyykrjlgtigupncx",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "EU2WT4NI": {
          "id": "EU2WT4NI",
          "name": "Fhmfpdpos",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "oKxPJ1c8": {
          "id": "oKxPJ1c8",
          "name": "Qpwe",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12},
          "score": 0
        },
      },
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
        "current_state_id": "pregame_state_id",
        "command": "start",
        "date": DateTime.now().toUtc().toIso8601String(),
        "next_state_id": "draw_state_id",
        "bonus": {
          "end_state": "abc",
          "end_game": {
            "WgRuBj1z": {
              "id": "WgRuBj1z",
              "name": "Qnrsiywg Fiuxthkt",
              "avatar": {"color": 15, "eyes": 12, "mouth": 12},
              "score": 1,
            },
            "AwROhV4k": {
              "id": "AwROhV4k",
              "name": "Aasmcyykrjlgtigupncx",
              "avatar": {"color": 15, "eyes": 12, "mouth": 12},
              "score": 1,
            },
            "EU2WT4NI": {
              "id": "EU2WT4NI",
              "name": "Fhmfpdpos",
              "avatar": {"color": 15, "eyes": 12, "mouth": 12},
              "score": 1,
            },
            "oKxPJ1c8": {
              "id": "oKxPJ1c8",
              "name": "Qpwe",
              "avatar": {"color": 15, "eyes": 12, "mouth": 12},
              "score": 0
            },
          }
        }
      },
      "henceforth_states": {
        "pregame_state_id": {"id": "pregame_state_id", "type": "pre_game"} as dynamic,
        "680b9959c4a0f77046faa933": {
          "type": "pick_word",
          "id": "680b9959c4a0f77046faa933",
          "round_notify": null,
          'player_id': "fDmSIumozqWBdX87AAAE",
          "words": [
            "ourselves",
            "choose",
            "for",
            "ourselves",
            "choose",
            "for",
            "ourselves",
            "choose",
            "for",
            "ourselves",
            "choose",
            "for",
            "ourselves",
            "choose",
            "for"
          ]
        } as dynamic,
        // "680cd9b9b34194c2298d16a4": {
        //   "type": "draw",
        //   "id": "680cd9b9b34194c2298d16a4",
        //   "player_id": "fDmSIumozqWBdX87AAA",
        //   "word": "the fish",
        //   "hint": "__ ___"
        // } as dynamic,
        "draw_state_id": {
          "type": 'draw',
          "id": "draw_state_id",
          "word": "abc",
          'hint': '___',
          "player_id": "fDmSIumozqWBdX87AAAE",
          "word_mode": "Normal",
          "end_state": "end_game",
          "points": {
            "WWEAmL4U": 76,
            "iBnJ6uBN": 63,
            "04lxSxZa": 1,
            "StzosDkc": 55,
            "ENrBp2BG": 10,
            "xHfT4tvh": 91,
            "8X1u11Wq": 44,
            "uZoEeKMu": 42,
            "ViWToJfv": 69,
            "5YX6ryba": 26,
            "PSS6IMpo": 81,
            "1GdAjnIA": 47,
            "i0ocogCF": 41,
            "c9wOaQfP": 56,
            "cfQZxYk4": 3,
            "rneIFu8k": 84,
            "BChA55fj": 19,
            "e71C9iWw": 39,
            "lvEf8oRL": 7,
            "HHl2q4QN": 51,
            "QKyqXknH": 35,
            "vfnTmOpu": 65,
            "QX6MHu2w": 58,
            "2uqWGm0r": 93,
            "KHnGbLQd": 52,
            "ER3emqQc": 19,
            "29juyknw": 22,
            "VvFoDY11": 34,
            "WgRuBj1z": 23,
            "AwROhV4k": 99,
            "EU2WT4NI": 11,
            "oKxPJ1c8": 17,
            "ahpR2f5C": 63,
            "MKxOJJPe": 6,
            "EevsJxoa": 24,
            "idYsCkH2": 11,
            "4BGszt2g": 75,
            "QzhpPWWl": 37,
            "GicOaeYT": 0,
            "zf7o7o1X": 9,
            "fDmSIumozqWBdX87AAAE": 100,
          } as dynamic
        } as dynamic
      },
      "quit_players": {
        "ahpR2f5C": {
          "id": "ahpR2f5C",
          "name": "quit player 1",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "MKxOJJPe": {
          "id": "MKxOJJPe",
          "name": "quit player 2",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "EevsJxoa": {
          "id": "EevsJxoa",
          "name": "quit player 3",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "idYsCkH2": {
          "id": "idYsCkH2",
          "name": "quit player 4",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "4BGszt2g": {
          "id": "4BGszt2g",
          "name": "quit player 5",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "QzhpPWWl": {
          "id": "QzhpPWWl",
          "name": "quit playuer 6",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "GicOaeYT": {
          "id": "GicOaeYT",
          "name": "quit player 7",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        },
        "zf7o7o1X": {
          "id": "zf7o7o1X",
          "name": "quit player 8",
          "avatar": {"color": 15, "eyes": 12, "mouth": 12}
        }
      }
    };

    MePlayer.inst = MePlayer.fromJSON(data['players']["fDmSIumozqWBdX87AAAE"]);
    Game.inst = PrivateGame._internal(data: data);
  }

  static void trigger() {
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
      OverlayController.cache(
          tag: 'join_but_get_banned',
          builder: () => GameDialog.error(
              content: Center(child: Text('dialog_content_join_but_get_banned'.tr)))).show();
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
                OverlayController.cache(
                    tag: 'kick interval',
                    builder: () => GameDialog.error(
                        content: Builder(
                            builder: (_) =>
                                Center(child: Text('dialog_content_kick_countdown'.tr))))).show();
                return;
              } else {
                // modify request package for ticket
                var ticketId = ticket['id'];
                var victimId = ticket['victim_id'];
                if (ticketId is String && victimId is String) {
                  requestPackage['id'] = ticketId;
                  requestPackage['victim_id'] = victimId;
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
    if (playersByMap.length < (Game.inst as PrivateGame).options['players']['min']) {
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
          GameDialog.error(content: Center(child: Text(res['reason'].toString()))).show();
        }
      });
    }
  }
}
