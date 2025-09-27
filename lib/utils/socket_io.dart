import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/pages/pages.dart';

import 'package:skribbl_client/utils/utils.dart';
import 'package:skribbl_client/widgets/widgets.dart';

// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIO {
  SocketIO._internal(this._socket) {
    socket.on('player_join', (dataList) {
      var data = (dataList as List<dynamic>).first;
      var inst = Game.inst;
      inst.addPlayer(data['player']);

      inst.addMessage((color) => PlayerJoinMessage(data: data['message'], backgroundColor: color));
    });

    socket.on('change_settings', (dataList) {
      var setting = (dataList as List).first;
      Game.inst.settings[setting['key']] = setting['value'];
    });

    socket.on('player_got_kicked', (dataList) {
      var data = dataList[0];
      var newCode = data['new_code'];
      var message = data['message'];
      var ticket = data['ticket'];

      if (newCode == null || message == null) {
        // find for 'used_by'
        _setTicket(ticket);
        Game.leave();
        GameDialog.discconected(content: Text("dialog_content_got_kicked".tr)).show();
      } else {
        Game.inst.roomCode = data['new_code'];
        Game.inst.removePlayer(ticket['victim_id']);
        Game.inst
            .addMessage((color) => PlayerGotKicked(backgroundColor: color, data: data['message']));
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
        GameDialog.discconected(content: Text('dialog_content_got_banned'.tr)).show();
      } else {
        Game.inst.roomCode = data['new_code'];
        Game.inst.removePlayer(victimId);
        Game.inst
            .addMessage((color) => PlayerGotBanned(backgroundColor: color, data: data['message']));
      }
    });

    _socket.on('player_leave', (dataList) {
      var playerLeaveEmit = dataList[0];
      var leftPlayerId = playerLeaveEmit['player_id'];
      // player list side
      var inst = Game.inst;

      // message side
      inst.addMessage((color) => PlayerLeaveMessage(data: playerLeaveEmit, backgroundColor: color));

      inst.removePlayer(leftPlayerId);
    });

    _socket.on('new_host', (dataList) {
      var inst = Game.inst;

      var msg =
          inst.addMessage((color) => NewHostMessage(data: dataList[0], backgroundColor: color));

      if (inst.playersByMap[msg.playerId] != null) {
        (inst as PrivateGame).hostPlayerId.value = msg.playerId;
      } else {
        Game.requestReload();
      }
    });

    socket.on('player_chat', (dataList) {
      var chatMsg = dataList[0];
      var playerId = chatMsg['player_id'];
      if (MePlayer.inst.mutedPlayerIds.contains(playerId)) return;

      Game.inst.addMessage((color) => PlayerChatMessage(data: chatMsg, backgroundColor: color));
      Get.find<PlayerController>(tag: playerId).showMessage(chatMsg['text']);
    });

    socket.on(
        'system_message',
        (dataList) => Game.inst
            .addMessage((color) => Message.fromJSON(backgroundColor: color, data: dataList[0])));

    socket.on('new_states', (dataList) => Game.inst.receiveStatusAndStates(dataList[0]));

    socket.on('draw:send_past', (dataList) => DrawReceiver.inst.addToPastSteps(dataList[0]));
    socket.on('draw:remove_past', (dataList) => DrawReceiver.inst.removePastStep(dataList[0]));

    socket.on('draw:start_current', (dataList) => DrawReceiver.inst.startCurrent(dataList[0]));
    socket.on('draw:update_current', (dataList) => DrawReceiver.inst.updateCurrent(dataList[0]));
    socket.on('draw:end_current', (dataList) => DrawReceiver.inst.endCurrent(dataList[0]));

    socket.on('hint', (dataList) => Get.find<HintController>().setHint(dataList[0], dataList[1]));

    socket.on('like_dislike', (dataList) {
      var msg = Game.inst
          .addMessage((color) => Message.fromJSON(backgroundColor: color, data: dataList[0]));

      if (msg is PlayerLikeMessage) {
        var inst = Game.inst;
        var state = inst.state.value;

        if (state is DrawStateMixin) {
          if (state.likedBy.contains(msg.playerId)) return;
          state.likedBy.add(msg.playerId);

          state.points[state.performerId] = msg.performerPoint;
          inst.playerPlusPoint(state.performerId, msg.performerPoint);
        }
      }
    });

    socket.on('guess_right', (dataList) {
      var msg = Game.inst
          .addMessage((color) => Message.fromJSON(backgroundColor: color, data: dataList[0]));
      if (msg is PlayerGuessedRight) {
        var state = Game.inst.state.value;
        if (state is DrawStateMixin && state.points[msg.playerId] == null) {
          state.points[msg.playerId] = msg.point;

          Game.inst.playerPlusPoint(msg.playerId, msg.point);
        }
      }
    });
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
