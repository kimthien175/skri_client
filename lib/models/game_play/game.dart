import 'package:cd_mobile/models/game_play/player.dart';
import 'package:cd_mobile/pages/gameplay/gameplay.dart';
import 'package:cd_mobile/pages/gameplay/widgets/game_settings.dart';
import 'package:cd_mobile/pages/gameplay/widgets/main_content/main_content.dart';
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
    inst.eventHandlers.onConnectError = (data) {
      inst.socket.disconnect();
      Get.find<HomeController>().isLoading.value = false;
      showDialog(
          context: Get.context!,
          builder: (context) => AlertDialog(
              title: const Text('Can not create private room right now'),
              content: Text(data.toString())));

      inst.eventHandlers.onConnectError = (data) {
        print('onConnectError');
        print('handled');
        print(data);
      };
    };

    inst.eventHandlers.onConnect = (data) {
      inst.socket.emitWithAck('init_private_room', MePlayer.inst.toJSON(),
          ack: (requestedRoomResult) {
        if (requestedRoomResult['success']) {
          var data = requestedRoomResult['data'];

          succeededCreatedRoomData = data;
          succeededCreatedRoomData['settings']['default']['use_custom_words_only'] = false;

          // set room owner name if empty
          if (MePlayer.inst.name.isEmpty) {
            MePlayer.inst.name = data['ownerName'];
          }

          // set default for PrivateGame settings
          settings = Map.from(data['settings']['default']);

          GameplayController.setUpPrivateGame();
          Get.toNamed('/gameplay');

          Get.find<HomeController>().isLoading.value = false;

          inst.eventHandlers.onConnect = (data) {
            print('onConnect');
            print('handled');
            print(data);
          };
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

    return this;
  }

  void startGame() {
    var inst = SocketIO.inst;
    var privateGameSettings = (Game.inst as PrivateGame).settings;

    if (privateGameSettings['use_custom_words_only']) {
      if (Get.find<GlobalKey<FormState>>().currentState!.validate()) {
        privateGameSettings['custom_words'] = CustomWordsInput.proceededWords;

        var goingToBePushed = (Game.inst as PrivateGame).getDifferentSettingsFromDefault();
        goingToBePushed['custom_words'] = CustomWordsInput.proceededWords;
        // start game with custom words
        print(goingToBePushed);
        //inst.socket.emit('start_private_game', goingToBePushed);
      } else {
        ScaffoldMessenger.of(Get.context!)
            .showSnackBar(SnackBar(content: Text('custom_words_input_invalidation_message'.tr)));
      }
    } else {
      // start game without custom words
      var goingToBePushed = (Game.inst as PrivateGame).getDifferentSettingsFromDefault();
      print(goingToBePushed);
     // inst.socket.emit('start_private_game', goingToBePushed);
    }

    Get.find<MainContentController>().showCanvas();
  }
}
