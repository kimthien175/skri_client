import 'package:cd_mobile/models/game_play/game.dart';
import 'package:cd_mobile/models/game_play/message.dart';
import 'package:cd_mobile/models/game_play/player.dart';
import 'package:cd_mobile/pages/gameplay/gameplay.dart';
import 'package:cd_mobile/pages/home/home.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:cd_mobile/utils/socket_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OwnedPrivateGame extends Game {
  static Future<void> init()async{
    // set up me player
    var me = MePlayer.inst;
    me.name = me.name.trim();


    Game.registerRoomErrorHandler('Can not create private room right now');

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
          me.isOwner = true;

          Game.inst = OwnedPrivateGame._internal(settings: settings.obs, remainingTime:0, currentRound: RxInt(1), rounds: RxInt(settings['rounds']), players: [me].obs, messages: [HostingMessage()].obs, succeededCreatedRoomData: succeededCreatedRoomData.obs, status: 'WAITING'.obs, word: ''.obs);

          GameplayController.setUpOwnedPrivateGame();
          Get.toNamed('/gameplay');

          Get.find<HomeController>().isLoading.value = false;

          inst.eventHandlers.onConnect = SessionEventHandlers.emptyOnConnect;
        } else {
          Get.find<HomeController>().isLoading.value = false;
          showDialog(
              context: Get.context!,
              builder: (context) => AlertDialog(
                  title: const Text('Can not create private room right now'),
                  content: Text(requestedRoomResult['data'].toString())));
        }
      });
    };

    inst.socket.connect();





    // int rounds=0;
    // Message msg = Message('');
    // return OwnedPrivateGame._internal(timeRemaining: 0, currentRound: 1, rounds: rounds, players: [MePlayer.inst], messages: [msg]);
  }

  /// SuccessCreateRoomData
  late RxMap<String, dynamic> succeededCreatedRoomData;

  /// DBRoomSettings
  late RxMap<String, dynamic> settings;

  OwnedPrivateGame._internal({required this.succeededCreatedRoomData, required this.settings, required super.status, required super.word, required super.remainingTime, required super.currentRound, required super.rounds, required super.players, required super.messages});
  Map<String, dynamic> getDifferentSettingsFromDefault() {
    Map<String, dynamic> result = {};
    var defaultSettings = succeededCreatedRoomData.value['settings']['default'];
    for (String key in settings.keys) {
      if (settings[key] != defaultSettings[key]) result[key] = settings[key];
    }
    return result;
  }

  // init when the main page is showing -> get main url
  String mainUrl = html.window.location.href;
  String get inviteLink => '$mainUrl?${succeededCreatedRoomData.value['code']}';

  // TODO: START PRIVATE GAME
  // void startGame() {
  //   // var inst = SocketIO.inst;
  //   var privateGameSettings = (Game.inst as OwnedPrivateGame).settings;

  //   if (privateGameSettings['use_custom_words_only']) {
  //     if (Get.find<GlobalKey<FormState>>().currentState!.validate()) {
  //       privateGameSettings['custom_words'] = CustomWordsInput.proceededWords;

  //       var goingToBePushed = (Game.inst as OwnedPrivateGame).getDifferentSettingsFromDefault();
  //       goingToBePushed['custom_words'] = CustomWordsInput.proceededWords;
  //       // start game with custom words
  //       // START PRIVATE GAME
  //       //inst.socket.emit('start_private_game', goingToBePushed);
  //     } else {
  //       ScaffoldMessenger.of(Get.context!)
  //           .showSnackBar(SnackBar(content: Text('custom_words_input_invalidation_message'.tr)));
  //     }
  //   } else {
  //     // start game without custom words
  //     //var goingToBePushed = (Game.inst as OwnedPrivateGame).getDifferentSettingsFromDefault();
  //     // START PRIVATE GAME
  //     // inst.socket.emit('start_private_game', goingToBePushed);
  //   }

  //   Get.find<MainContentController>().showCanvas();
  // }





  // OwnedPrivateGame requestInitRoom() {
  //   Game.registerRoomErrorHandler('Can not create private room right now');

  //   var inst = SocketIO.inst;
  //   inst.eventHandlers.onConnect = (_) {
  //     inst.socket.emitWithAck('init_private_room', MePlayer.inst.toJSON(),
  //         ack: (requestedRoomResult) {
  //       if (requestedRoomResult['success']) {
  //         var data = requestedRoomResult['data'];

  //         succeededCreatedRoomData = data;
  //         succeededCreatedRoomData['settings']['default']['use_custom_words_only'] = false;

  //         // set room owner name if empty
  //         if (MePlayer.inst.name.isEmpty) {
  //           MePlayer.inst.name = data['ownerName'];
  //         }

  //         // set default for PrivateGame settings
  //         settings = Map.from(data['settings']['default']);

  //         GameplayController.setUpOwnedPrivateGame();
  //         Get.toNamed('/gameplay');

  //         Get.find<HomeController>().isLoading.value = false;

  //         inst.eventHandlers.onConnect = SessionEventHandlers.emptyOnConnect;
  //       } else {
  //         Get.find<HomeController>().isLoading.value = false;
  //         showDialog(
  //             context: Get.context!,
  //             builder: (context) => AlertDialog(
  //                 title: const Text('Can not create private room right now'),
  //                 content: Text(requestedRoomResult['data'].toString())));
  //       }
  //     });
  //   };

  //   inst.socket.connect();

  //   return this;
  // }
}
