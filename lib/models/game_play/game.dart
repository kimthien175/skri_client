import 'package:cd_mobile/models/game_play/player.dart';
import 'package:cd_mobile/pages/gameplay/gameplay.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/utils/socket_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

abstract class Game<GAME_TYPE extends Game<GAME_TYPE>> {
  Game(this.players);
  static Game? _inst;
  static Game get inst => _inst!;

  List<Player> players;

  static void initPrivateRoom() {
    _inst = PrivateGame.init();
  }

  static empty() {
    _inst = null;
  }
}

class PrivateGame extends Game<PrivateGame> {
  PrivateGame(super.players);
  static PrivateGame init() {
    // set up MePlayer
    var me = MePlayer.inst;
    me.isOwner = true;
    me.name = me.name.trim();

    return PrivateGame([me]).requestRoom();
  }

  /// SuccessCreateRoomData
  Map<String, dynamic> succeededCreatedRoomData = {};

  /// DBRoomSettings
  late Map<String, dynamic> settings;
  Map<String, dynamic> getDifferentSettingsFromDefault() {
    Map<String, dynamic> result = {};
    var defaultSettings = succeededCreatedRoomData['settings']['default'];
    for (String key in settings.keys) {
      if (settings[key] != defaultSettings[key]) result[key] = settings[key];
    }
    return result;
  }

  // init when the main page is showing -> get main url
  String mainUrl = html.window.location.href;
  String get inviteLink => '$mainUrl?${succeededCreatedRoomData['code']}';

  PrivateGame requestRoom() {
    var inst = SocketIO.inst;

    inst.eventHandlers.onConnect = () {
      inst.socket.emitWithAck('init_room', MePlayer.inst.name, ack: (requestedRoomResult) {
        if (requestedRoomResult['error'] != null) {
          Get.find<HomeController>().isLoading.value = false;
          showDialog(
              context: Get.context!,
              builder: (context) => AlertDialog(
                  title: const Text('Can not create private room right now'),
                  content: Text(requestedRoomResult['error'].toString())));
        } else {
          var succeeded = requestedRoomResult['ok'];

          succeededCreatedRoomData = succeeded;
          succeededCreatedRoomData['settings']['default']['use_custom_words_only'] = false;

          // set room owner name if empty
          if (MePlayer.inst.name.isEmpty) {
            MePlayer.inst.name = succeeded['ownerName'];
          }

          // set default for PrivateGame settings
          settings = Map.from(succeeded['settings']['default']);

          GameplayController.setUpPrivateGame();
          Get.toNamed('/gameplay');

          Get.find<HomeController>().isLoading.value = false;

          inst.eventHandlers.onConnect = () {};
        }
      });
    };

    inst.socket.connect();

    return this;
  }
}
