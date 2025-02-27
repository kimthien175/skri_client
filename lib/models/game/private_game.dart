import 'package:skribbl_client/models/game/game.dart';

import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/socket_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/storage.dart';

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

  static int dialogOpenCount = 0;
  static void handleOnConnectError(String title) {
    // inst.eventHandlers.onConnectError = (error) {
    //   if (Get.currentRoute == '/') {
    //     SocketIO.inst.socket.disconnect();
    //     // at home page
    //     if (dialogOpenCount == 0) {
    //       dialogOpenCount++;

    //       Get.defaultDialog(
    //           title: title,
    //           middleText: '${"create_private_room_error_content".tr}\n${error.toString()}',
    //           onCancel: () {
    //             LoadingOverlay.inst.hide();

    //             dialogOpenCount = 0;
    //           },
    //           barrierDismissible: false);
    //     }
    //   } else {
    //     // at gameplay page
    //     if (!LoadingOverlay.inst.isShowing) {
    //       LoadingOverlay.inst.show();
    //     }

    //     if (dialogOpenCount == 0) {
    //       dialogOpenCount++;
    //       Get.defaultDialog(
    //           title: '${'gameplay_connection_error'.tr}\n',
    //           middleText: error.toString(),
    //           onCancel: () {
    //             Game.inst.leave();
    //           },
    //           onConfirm: () {
    //             Get.back();
    //           },
    //           barrierDismissible: false);
    //     }
    //   }
    // };

    // inst.eventHandlers.onReconnect = (_) => dialogOpenCount = 0;
  }

  void startGame() {
    if (playersByList.length < (Game.inst as PrivateGame).options['players']['min']) {
      addMessage((Color color) => RequiredMinimumPlayersToStartMessage(
            backgroundColor: color,
          ));
      return;
    }
    // gather settings, settings from dropdown and check button is saved in settings already
    // now have left only the custom words
    if (Get.find<GameSettingsController>().formKey.currentState!.validate()) {
      SocketIO.inst.socket.emit('start_private_game', Game.inst.settings);
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

extension _SubDate on DateTime {
  Duration operator -(DateTime other) => difference(other);
}
