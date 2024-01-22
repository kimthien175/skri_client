import 'package:cd_mobile/models/game/game.dart';
import 'package:cd_mobile/models/game/player.dart';
import 'package:cd_mobile/pages/gameplay/gameplay.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/utils/datetime.dart';
import 'package:cd_mobile/utils/socket_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class PrivateGame extends Game {
  /// SuccessCreateRoomData
  late Map<String, dynamic> succeededCreatedRoomData;

  /// DBRoomSettings
  late Map<String, dynamic> settings;
  void updateSettings(String key, dynamic value) {
    if (key == 'rounds') {
      rounds.value = value;
    }
    settings[key] = value;
  }

  PrivateGame._internal(
      {required this.succeededCreatedRoomData,
      required this.settings,
      required super.status,
      required super.word,
      required super.remainingTime,
      required super.currentRound,
      required super.rounds,
      required super.playersByList,
      required super.roomCode});

  String get inviteLink => '${html.window.location.host}/?$roomCode';

  static Future<void> host() async {
    // set up me player
    var me = MePlayer.inst;
    me.name = me.name.trim();

    handleOnConnectError("create_private_room_error_title".tr);

    var inst = SocketIO.inst;
    inst.eventHandlers.onConnect = (_) {
      inst.socket.emitWithAck('init_private_room', MePlayer.inst.toJSON(),
          ack: (requestedRoomResult) {
        if (requestedRoomResult['success']) {
          var data = requestedRoomResult['data'];

          Map<String, dynamic> succeededCreatedRoomData = data;
          succeededCreatedRoomData['settings']['default']['use_custom_words_only'] = false;

          // set default for PrivateGame settings
          var settings = Map<String, dynamic>.from(data['settings']['default']);

          // set room owner name if empty
          if (MePlayer.inst.name.isEmpty) {
            MePlayer.inst.name = data['ownerName'];
          }
          MePlayer.inst.id = data['player_id'];
          me.isOwner = true;

          Game.inst = PrivateGame._internal(
              roomCode: data['code'],
              settings: settings,
              remainingTime: 0,
              currentRound: RxInt(1),
              rounds: RxInt(settings['rounds']),
              playersByList: [me as Player].obs,
              succeededCreatedRoomData: succeededCreatedRoomData,
              status: 'waiting'.obs,
              word: ''.obs);

          Game.inst.addMessage(data['message']);

          GameplayController.setUpOwnedPrivateGame();
          Get.to(() => const GameplayPage(),
              binding: GameplayBinding(), transition: Transition.noTransition);
        } else {
          showDialog(
              context: Get.context!,
              builder: (context) => AlertDialog(
                  title: const Text('Can not create private room right now'),
                  content: Text(requestedRoomResult['data'].toString())));
        }

        Get.find<HomeController>().isLoading.value = false;
        inst.eventHandlers.onConnect = SessionEventHandlers.emptyOnConnect;
      });
    };

    inst.socket.connect();
  }

  static void join(String roomCode) {
    // set up me player
    var me = MePlayer.inst;
    me.name = me.name.trim();

    handleOnConnectError("join_private_room_error_title".tr);

    var inst = SocketIO.inst;
    inst.eventHandlers.onConnect = (_) {
      inst.socket
          .emitWithAck('join_private_room', {'player': MePlayer.inst.toJSON(), 'code': roomCode},
              ack: (requestedJoiningRoomResult) {
        if (requestedJoiningRoomResult['success']) {
          var successJoinRoom = requestedJoiningRoomResult['data'];

          // modify MePlayer
          if (me.name.isEmpty) {
            me.name = successJoinRoom['player']['name'];
          }
          me.id = successJoinRoom['player']['id'];

          var joinRoomData = successJoinRoom['room'];

          // remainingTime
          int remainingTime = 0;
          if (joinRoomData['currentRoundStartedAt'] != null) {
            remainingTime = hasPassed(joinRoomData['currentRoundStartedAt']).inSeconds;
          }

          // currentRound
          int currentRound = 1;
          if (joinRoomData['currentRound'] != null) {
            currentRound = joinRoomData['currentRound'];
          }

          // rounds
          int rounds = joinRoomData['settings']['rounds'];

          // status
          String status = joinRoomData['status'];

          // word
          String word = '';
          List<dynamic>? words = joinRoomData['words'];
          if (words != null) {
            word = words[words.length - 1];
          }

          // players
          List<dynamic> rawPlayers = joinRoomData['players'];
          List<Player> players = [];
          for (dynamic rawPlayer in rawPlayers) {
            if (rawPlayer['id'] == me.id) {
              players.add(MePlayer.inst);
            } else {
              players.add(Player.fromJSON(rawPlayer));
            }
          }

          String roomCode = joinRoomData['code'];

          Game.inst = PrivateGame._internal(
              remainingTime: remainingTime,
              currentRound: currentRound.obs,
              rounds: rounds.obs,
              status: status.obs,
              word: word.obs,
              playersByList: players.obs,
              roomCode: roomCode,
              succeededCreatedRoomData: {},
              settings: {});

          // set up gameplay
          GameplayController.setUpPrivateGameForGuest();
          Get.find<HomeController>().isLoading.value = false;

          Get.to(() => const GameplayPage(),
              binding: GameplayBinding(), transition: Transition.noTransition);

          for (dynamic rawMessage in joinRoomData['messages']) {
            Game.inst.addMessage(rawMessage);
          }
        } else {
          Get.find<HomeController>().isLoading.value = false;
          showDialog(
              context: Get.context!,
              builder: (context) => AlertDialog(
                  title: Text('wrong_private_room_code'.tr),
                  content: Text(requestedJoiningRoomResult['data'].toString())));
        }

        inst.eventHandlers.onConnect = SessionEventHandlers.emptyOnConnect;
      });
    };

    inst.socket.connect();
  }

  static int dialogOpenCount = 0;
  static void handleOnConnectError(String title) {
    var inst = SocketIO.inst;
    inst.eventHandlers.onConnectError = (error) {
      if (Get.currentRoute == '/') {
        // at home page
        if (dialogOpenCount == 0) {
          dialogOpenCount++;

          Get.defaultDialog(
              title: title,
              middleText: '${"create_private_room_error_content".tr}\n${error.toString()}',
              onCancel: () {
                Get.find<HomeController>().isLoading.value = false;

                SocketIO.inst.socket.disconnect();
                dialogOpenCount=0;
              },
              barrierDismissible: false);
        }
      } else {
        // at gameplay page
        if (!Get.find<GameplayController>().isLoading.value) {
          Get.find<GameplayController>().isLoading.value = true;
        }

        if (dialogOpenCount == 0) {
          dialogOpenCount++;
          Get.defaultDialog(
              title: '${'gameplay_connection_error'.tr}\n',
              middleText: error.toString(),
              onCancel: () {
                Game.inst.leave();
              },
              onConfirm: () {
              Get.back();
              },
              barrierDismissible: false);
        }
      }
    };

    inst.eventHandlers.onReconnect = (_) => dialogOpenCount = 0;
  }

  Map<String, dynamic> getDifferentSettingsFromDefault() {
    Map<String, dynamic> result = {};
    var defaultSettings = succeededCreatedRoomData['settings']['default'];
    for (String key in settings.keys) {
      if (settings[key] != defaultSettings[key]) result[key] = settings[key];
    }
    return result;
  }
}
