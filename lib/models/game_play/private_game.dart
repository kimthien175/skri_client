// class PrivateGame extends Game{
//   PrivateGame(super.players);

//     static Future<PrivateGame> join(String roomCode) async {
//     OwnedPrivateGame.registerRoomErrorHandler('Can not join private room right now');

//     var inst = SocketIO.inst;
//     inst.eventHandlers.onConnect = (_) {
//       inst.socket
//           .emitWithAck('join_private_room', {'player': MePlayer.inst.toJSON(), 'code': roomCode},
//               ack: (requestedRoomResult) {
//         if (requestedRoomResult['success']) {
//           var data = requestedRoomResult['data'];

//           // set room owner name if empty
//           if (MePlayer.inst.name.isEmpty) {
//             MePlayer.inst.name = data['player_name'];
//           }

//           var players =
//           GameplayController.setUpPrivateGame();
//           Get.toNamed('/gameplay');

//           Get.find<HomeController>().isLoading.value = false;

//           inst.eventHandlers.onConnect = (data) {
//             print('onConnect');
//             print('handled');
//             print(data);
//           };
//         } else {
//           Get.find<HomeController>().isLoading.value = false;
//           showDialog(
//               context: Get.context!,
//               builder: (context) => AlertDialog(
//                   title: const Text('Can not create private room right now'),
//                   content: Text(requestedRoomResult['data'].toString())));
//         }
//       });
//     };

//     inst.socket.connect();

//     return PrivateGame([]);
//   }
// }

import 'package:cd_mobile/models/game_play/game.dart';
import 'package:cd_mobile/models/game_play/player.dart';
import 'package:cd_mobile/pages/gameplay/gameplay.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/utils/socket_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cd_mobile/utils/datetime.dart';

class PrivateGame extends Game {
  static void init(String roomCode) {
    // set up me player
    var me = MePlayer.inst;
    me.name = me.name.trim();

    Game.registerRoomErrorHandler('Can not join private room right now');

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
              roomCode: roomCode);

          // set up gameplay
          GameplayController.setUpPrivateGameForGuest();

          Get.to(() => const GameplayPage(),
              binding: GameplayBinding(), transition: Transition.noTransition);

          for (dynamic rawMessage in joinRoomData['messages']) {
            Game.inst.addMessage(rawMessage);
          }
        } else {
          showDialog(
              context: Get.context!,
              builder: (context) => AlertDialog(
                  title: const Text('Can not create private room right now'),
                  content: Text(requestedJoiningRoomResult['data'].toString())));
        }

        Get.find<HomeController>().isLoading.value = false;
        inst.eventHandlers.onConnect = SessionEventHandlers.emptyOnConnect;
      });
    };

    inst.socket.connect();
  }

  PrivateGame._internal(
      {required super.remainingTime,
      required super.currentRound,
      required super.rounds,
      required super.status,
      required super.word,
      required super.playersByList,
      required super.roomCode});
}
