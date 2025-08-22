import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/game/game.dart';
import 'package:skribbl_client/models/game/state/draw/draw.dart';
import 'package:skribbl_client/pages/gameplay/widgets/utils.dart';

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
      var newPlayer = Player.fromJSON(data['player']);
      inst.playersByList.add(newPlayer);
      inst.playersByMap[newPlayer.id] = newPlayer;
      Get.put(PlayerController(), tag: newPlayer.id);

      inst.addMessage((color) => PlayerJoinMessage(data: data['message'], backgroundColor: color));
    });

    socket.on('change_settings', (dataList) {
      var setting = (dataList as List).first;
      Game.inst.settings[setting['key']] = setting['value'];
    });

    socket.on('player_got_kicked', (dataList) async {
      var update = (dataList as List).first;
      var victimId = update['victim_id'];

      if (victimId == MePlayer.inst.id) {
        // find for 'used_by'
        _setTicket(update);
        Game.leave();
        GameDialog.discconected(content: Center(child: Text("dialog_content_got_kicked".tr)))
            .show();
      } else {
        Game.inst.roomCode = update['new_code'];
        Game.inst.removePlayer(victimId);
        Game.inst.addMessage(
            (color) => PlayerGotKicked(backgroundColor: color, data: update['message']));
      }
    });

    socket.on('player_got_banned', (dataList) {
      var data = dataList[0];
      String victimId = data['victim_id'];
      if (victimId == MePlayer.inst.id) {
        //#region save to cache
        List<dynamic> codes = [Game.inst.roomCode];
        var homeController = Get.find<HomeController>();
        if (homeController.hasCode &&
            homeController.isPrivateRoomCodeValid &&
            homeController.privateRoomCode != Game.inst.roomCode) {
          codes.add(homeController.privateRoomCode);
        }

        var existingBanList = Storage.data['ban'];
        if (existingBanList is List) {
          codes.addAll(existingBanList);
        }
        Storage.set(['ban'], codes);
        //#endregion

        Game.leave();
        GameDialog.discconected(content: Center(child: Text('dialog_content_got_banned'.tr)))
            .show();
      } else {
        Game.inst.roomCode = data['new_code'];
        Game.inst.removePlayer(victimId);
        Game.inst
            .addMessage((color) => PlayerGotBanned(backgroundColor: color, data: data['message']));
      }
    });

    _socket.on('player_leave', (data) => onPlayerLeave(data[0]));

    _socket.on('new_host', (data) => onNewHost(data[0]));

    socket.on('player_chat', (dataList) {
      var chatMsg = dataList[0];
      var playerId = chatMsg['player_id'];
      if (Game.inst.playersByMap[playerId]?.isMuted == true) return;
      Game.inst.addMessage((color) => PlayerChatMessage(data: chatMsg, backgroundColor: color));
      Get.find<PlayerController>(tag: playerId).showMessage(chatMsg['text']);
    });

    socket.on('system_message', (dataList) {
      var msg = dataList[0];
      Game.inst.addMessage((color) => Message.fromJSON(backgroundColor: color, data: msg));
    });

    socket.on('new_states', (dataList) => Game.inst.receiveStatusAndStates(dataList[0]));

    socket.on('draw:send_past', (dataList) => DrawReceiver.inst.addToPastSteps(dataList[0]));
    socket.on('draw:remove_past', (dataList) => DrawReceiver.inst.removePastStep(dataList[0]));

    socket.on('draw:start_current', (dataList) => DrawReceiver.inst.startCurrent(dataList[0]));
    socket.on('draw:update_current', (dataList) => DrawReceiver.inst.updateCurrent(dataList[0]));
    socket.on('draw:end_current', (_) => DrawReceiver.inst.endCurrent());

    socket.on('hint', (dataList) => {Get.find<HintController>().setHint(dataList[0], dataList[1])});
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

    // message side
    inst.addMessage((color) => PlayerLeaveMessage(data: playerLeaveEmit, backgroundColor: color));

    inst.removePlayer(leftPlayerId);
  }

  // TODO: NOTE STATE
  onNewHost(newHostEmit) {
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

void _setTicket(dynamic ticket) {
  var cachedTicket = {'date': DateTime.now().toIso8601String(), ...ticket};
  if (Storage.data['kick'] != null) {
    for (var entry in (Storage.data['kick'] as Map<String, dynamic>).entries) {
      if (entry.value['used_by'] == Game.inst.hashCode) {
        Storage.set(['kick', entry.key], cachedTicket);
        return;
      }
    }
  }
  Storage.set(['kick', Game.inst.roomCode], cachedTicket);
}
