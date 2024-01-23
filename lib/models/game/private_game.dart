import 'package:cd_mobile/models/game/game.dart';
import 'package:cd_mobile/models/game/player.dart';
import 'package:cd_mobile/pages/gameplay/gameplay.dart';
import 'package:cd_mobile/pages/gameplay/widgets/game_settings.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/utils/datetime.dart';
import 'package:cd_mobile/utils/socket_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class PrivateGame extends Game {
  PrivateGame._internal(
      {required this.options,
      required this.settings,
      required super.status,
      required super.word,
      required super.remainingTime,
      required super.currentRound,
      required super.rounds,
      required super.playersByList,
      required super.roomCode});

  Map<String, dynamic> options;
  RxMap<String, dynamic> settings;
  void changeSettings(String key, dynamic value){
        if (key == 'rounds') {
      rounds.value = value;
    }
    settings[key] = value;
    SocketIO.inst.socket.emit('change_settings',{key: value});
  }

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
          var createdRoom = requestedRoomResult['data'];

          Map<String, dynamic> settings = createdRoom['settings']['default'];

          // set room owner name if empty
          if (MePlayer.inst.name.isEmpty) {
            MePlayer.inst.name = createdRoom['ownerName'];
          }
          MePlayer.inst.id = createdRoom['player_id'];
          me.isOwner = true;

          Game.inst = PrivateGame._internal(
              roomCode: createdRoom['code'],
              settings: settings.obs,
              remainingTime: 0,
              currentRound: RxInt(1),
              rounds: RxInt(settings['rounds']),
              // ignore: unnecessary_cast
              playersByList: [me as Player].obs,
              status: 'waiting'.obs,
              word: ''.obs,
              options: createdRoom['settings']['options']);

          Game.inst.addMessage(createdRoom['message']);

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
          var roomAndNewPlayer = requestedJoiningRoomResult['data'];

          // modify MePlayer
          if (me.name.isEmpty) {
            me.name = roomAndNewPlayer['player']['name'];
          }
          me.id = roomAndNewPlayer['player']['id'];

          var room = roomAndNewPlayer['room'];

          // remainingTime
          int remainingTime = 0;
          if (room['currentRoundStartedAt'] != null) {
            remainingTime = hasPassed(room['currentRoundStartedAt']).inSeconds;
          }

          // currentRound
          int currentRound = 1;
          if (room['currentRound'] != null) {
            currentRound = room['currentRound'];
          }

          // rounds
          int rounds = room['settings']['rounds'];

          // status
          String status = room['status'];

          // word
          String word = '';
          List<dynamic>? words = room['words'];
          if (words != null) {
            word = words[words.length - 1];
          }

          // players
          List<dynamic> rawPlayers = room['players'];
          List<Player> players = [];
          for (dynamic rawPlayer in rawPlayers) {
            if (rawPlayer['id'] == me.id) {
              players.add(MePlayer.inst);
            } else {
              players.add(Player.fromJSON(rawPlayer));
            }
          }

          String roomCode = room['code'];

          Game.inst = PrivateGame._internal(
              remainingTime: remainingTime,
              currentRound: currentRound.obs,
              rounds: rounds.obs,
              status: status.obs,
              word: word.obs,
              playersByList: players.obs,
              roomCode: roomCode,
              options: room['options'],
              settings: (room['settings']as Map<String,dynamic>).obs);

          // set up gameplay
          GameplayController.setUpPrivateGameForGuest();
          Get.find<HomeController>().isLoading.value = false;

          Get.to(() => const GameplayPage(),
              binding: GameplayBinding(), transition: Transition.noTransition);

          for (dynamic rawMessage in room['messages']) {
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
                dialogOpenCount = 0;
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

  void startGame(){
    // gather settings, settings from dropdown and check button is saved in settings already
    // now have left only the custom words
    if (Get.find<GlobalKey<FormState>>().currentState!.validate()){
      // start game
      print('CustomWordsInput');
      print(CustomWordsInput.proceededWords);
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
