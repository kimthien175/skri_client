import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/game/game.dart';
import 'package:skribbl_client/utils/storage.dart';

import 'package:skribbl_client/utils/utils.dart';
import 'package:skribbl_client/widgets/dialog/dialog.dart';

// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../pages/pages.dart';

class SocketIO {
  SocketIO._internal(this._socket) {
    socket.on('player_join', (dataList) {
      var data = (dataList as List<dynamic>).first;
      var inst = Game.inst;
      var newPlayer = Player.fromJSON(data['players']);
      inst.playersByList.add(newPlayer);
      inst.playersByMap[newPlayer.id] = newPlayer;
      Get.put(PlayerController(), tag: newPlayer.id);

      inst.addMessage((color) => PlayerJoinMessage(data: data['messages'], backgroundColor: color));

      inst.roundWhiteList.add(data['round_white_list']);
    });

    socket.on('change_settings', (dataList) {
      var setting = (dataList as List).first;
      Game.inst.settings[setting['key']] = setting['value'];
    });

    socket.on('player_got_kicked', (dataList) async {
      var update = (dataList as List).first;
      var victimId = update['victim_id'];

      if (victimId == MePlayer.inst.id) {
        Storage.set([Game.inst.roomCode], {...update, 'type': 'kick'});
        Game.leave();
        GameDialog.error(content: Center(child: Text("dialog_content_got_kicked".tr))).show();
      } else {
        Game.inst.roomCode = update['new_code'];
        Game.inst.removePlayer(victimId);
        Game.inst.addMessage(
            (color) => PlayerGotKicked(backgroundColor: color, data: update['message']));
      }
    });

    // _socket.on('start_private_game', (data) {
    //   var state = Game.inst.state.value;
    //   assert(state is PreGameState);

    //   if (data) state.end(data);
    // });

    // _socket.on('player_leave', onPlayerLeave);

    // _socket.on('new_host', onNewHost);

    // _socket.on('host_leave', (hostLeaveEmit) {
    //   onPlayerLeave(hostLeaveEmit[0]);
    //   onNewHost(hostLeaveEmit[1]);
    // });

    socket.on('player_chat', (dataList) {
      var chatMsg = dataList[0];
      var playerId = chatMsg['player_id'];
      if (Game.inst.playersByMap[playerId]?.isMuted == true) return;
      Game.inst.addMessage((color) => PlayerChatMessage(data: chatMsg, backgroundColor: color));
      Get.find<PlayerController>(tag: playerId).showMessage(chatMsg['text']);
    });

    // _socket.on('choose_word', (chooseWordPkg) {
    //   Game.inst.state.value.next(chooseWordPkg).then((value) => Game.inst.state.value = value);
    // });
  }

  static Future<void> initSocket() async {
    //  await FlutterUdid.consistentUdid.then((value) => print(value)).catchError((e) => print(e));
    var socket = IO.io(
        API.inst.uri,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            // .setExtraHeaders({
            //   'device_id': await FlutterUdid.consistentUdid.catchError((e) {
            //     print('UUID ERROR');
            //     return print(e);
            //   })
            // })
            .disableAutoConnect()
            .build());

    SocketIO._inst = SocketIO._internal(socket);
  }

  static SocketIO? _inst;

  static SocketIO get inst => _inst!;

  late final IO.Socket _socket;
  IO.Socket get socket => _socket;

  // void connect() {
  //   _socket.onConnectError((data) {
  //     GameDialog.cache(
  //         tag: data.toString(),
  //         builder: () => GameDialog.error(
  //             content: Text(data.toString()),
  //             buttons: GameDialogButtons.okay(onTap: (quit) async {
  //               _socket.disconnect();
  //               quit();
  //             }))).showOnce();
  //   });
  //   socket.connect();
  // }

  // late final SessionEventHandlers eventHandlers;

  onPlayerLeave(dynamic playerLeaveEmit) {
    var leftPlayerId = playerLeaveEmit['player_id'];
    // player list side
    var inst = Game.inst;
    inst.playersByList.removeWhere((element) => element.id == leftPlayerId);

    // message side
    inst.addMessage((color) => PlayerLeaveMessage(data: playerLeaveEmit, backgroundColor: color));

    inst.playersByMap.removeWhere((key, value) => key == leftPlayerId);
  }

  // TODO: NOTE STATE
  onNewHost(dynamic newHostEmit) {
    var inst = Game.inst;
    var newHost = inst.playersByMap[newHostEmit['player_id']]!;
    (inst as PrivateGame).hostPlayerId.value = newHost.id;
    inst.playersByList.refresh();

    inst.addMessage((color) => NewHostMessage(data: newHostEmit, backgroundColor: color));

    // if (MePlayer.inst.isOwner == true) {
    //   var game = (Game.inst as PrivateGame);
    //   game.settings.value = newHostEmit['settings'];
    //   if (game.state.value is WaitForSetupState) {
    //     Get.find<GameSettingsController>().isCovered.value = false;
    //   }
    // }
  }
}

typedef SocketCallback = dynamic Function(dynamic data);
