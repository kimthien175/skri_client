import 'package:flutter/material.dart';
import 'package:skribbl_client/models/game/game.dart';

import 'package:skribbl_client/pages/gameplay/widgets/game_settings.dart';
import 'package:skribbl_client/utils/utils.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIO {
  SocketIO._internal() {
    _socket = IO.io(
        API.inst.uri, IO.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build());

    // eventHandlers = SessionEventHandlers.initWithSocket(socket: _socket);

    _socket.onAny((eventName, data) {
      print('[onAny]');
      print(eventName);
      print(data);
    });

    _socket.on('player_join', (newPlayerEmit) {
      var inst = Game.inst;
      var newPlayer = Player.fromJSON(newPlayerEmit['player']);
      inst.playersByList.add(newPlayer);
      inst.playersByMap[newPlayer.id] = newPlayer;

      inst.addMessage((color) => PlayerJoinMessage(
          playerName: newPlayerEmit['message']['player_name'], backgroundColor: color));
    });

    _socket.on('player_leave', onPlayerLeave);

    _socket.on('new_host', onNewHost);

    _socket.on('host_leave', (hostLeaveEmit) {
      onPlayerLeave(hostLeaveEmit[0]);
      onNewHost(hostLeaveEmit[1]);
    });

    _socket.on('player_chat', (chatMsg) {
      Game.inst.addMessage((color) => PlayerChatMessage(
          playerName: chatMsg['player_name'], chat: chatMsg['chat'], backgroundColor: color));
      // TODO: DISPLAY TOOLTIP BESIDE PLAYER CARD
    });

    _socket.on('change_settings', (setting) {
      var game = (Game.inst as PrivateGame);

      var entry = (setting as Map<String, dynamic>).entries.first;
      var key = entry.key;
      var value = entry.value;

      if (key == 'rounds') {
        game.rounds.value = value;
      }
      (Game.inst as PrivateGame).settings[key] = value;
    });

    _socket.on('start_private_game', (startPrivateGamePackage) {
      // Start round 1 and choosing word
      Game.inst.state.value
          .next(startPrivateGamePackage)
          .then((value) => Game.inst.state.value = value);
    });

    _socket.on('choose_word', (chooseWordPkg) {
      Game.inst.state.value.next(chooseWordPkg).then((value) => Game.inst.state.value = value);
    });
  }
  static final SocketIO _inst = SocketIO._internal();

  static SocketIO get inst => _inst;

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
    inst.addMessage((color) =>
        PlayerLeaveMessage(playerName: playerLeaveEmit['player_name'], backgroundColor: color));

    inst.playersByMap.removeWhere((key, value) => key == leftPlayerId);
  }

  // TODO: NOTE STATE
  onNewHost(dynamic newHostEmit) {
    var inst = Game.inst;
    var newHost = inst.playersByMap[newHostEmit['player_id']]!;
    newHost.isOwner = true;
    inst.playersByList.refresh();

    inst.addMessage(
        (color) => NewHostMessage(playerName: newHostEmit['player_name'], backgroundColor: color));

    if (MePlayer.inst.isOwner == true) {
      var game = (Game.inst as PrivateGame);
      game.settings.value = newHostEmit['settings'];
      if (game.state.value is WaitForSetupState) {
        Get.find<GameSettingsController>().isCovered.value = false;
      }
    }
  }
}

typedef SocketCallback = dynamic Function(dynamic data);

class SessionEventHandlers {
  SessionEventHandlers.initWithSocket({required IO.Socket socket}) {
    // this.onConnect = onConnect ?? emptyOnConnect;
    // socket.onConnect((data) => this.onConnect(data));

    // this.onConnectError = onConnectError ?? emptyOnConnectError;
    // socket.onConnectError((data) => this.onConnectError(data));

    // this.onConnectTimeout = onConnectTimeout ?? emptyOnConnectTimeout;
    // socket.onConnectTimeout((data) => this.onConnectTimeout(data));

    // this.onConnecting = onConnecting ?? emptyOnConnecting;
    // socket.onConnecting((data) => this.onConnecting(data));

    // this.onDisconnect = onDisconnect ?? emptyOnDisconnect;
    // socket.onDisconnect((data) => this.onDisconnect(data));

    // this.onReconnect = onReconnect ?? emptyOnReconnect;
    // socket.onReconnect((data) => this.onReconnect(data));

    // this.onReconnectAttempt = onReconnectAttempt ?? emptyOnReconnectAttempt;
    // socket.onReconnectAttempt((data) => this.onReconnectAttempt(data));

    // this.onReconnectFailed = onReconnectFailed ?? emptyOnReconnectFailed;
    // socket.onReconnectFailed((data) => this.onReconnectFailed(data));

    // this.onReconnectError = onReconnectError ?? emptyOnReconnectError;
    // socket.onReconnectError((data) => this.onReconnectError(data));

    // this.onReconnecting = onReconnecting ?? emptyOnReconnecting;
    // socket.onReconnecting((data) => this.onReconnecting(data));
  }
  // late void Function(dynamic) onConnect;
  // static emptyOnConnect(data) {
  //   print('onConnect');
  //   print(data);
  // }

  // late void Function(dynamic) onConnectError;
  // static emptyOnConnectError(data) {
  //   print('onConnectionError');
  //   print(data);
  // }

  // late void Function(dynamic) onConnectTimeout;
  // static emptyOnConnectTimeout(data) {
  //   print('onConnectTimeout');
  //   print(data);
  // }

  // late void Function(dynamic) onConnecting;
  // static emptyOnConnecting(data) {
  //   print('onConnecting');
  //   print(data);
  // }

  // late void Function(dynamic) onDisconnect;
  // static emptyOnDisconnect(data) {
  //   print('onDisconnect');
  //   print(data);
  // }

  dynamic defaultOnError(dynamic data) {
    var socket = SocketIO.inst._socket;
    // show error dialog, get to the main page on quit

    // clear stuff
    LoadingOverlay.inst.hide();
    socket.disconnect();

    GameDialog.cache(
        tag: data.toString(),
        builder: () => GameDialog.error(
            content: Text(data.toString()),
            buttons: GameDialogButtons.okay(onTap: (quit) async {
              // disconnect
              socket.disconnect();

              await quit();

              // out to home page
              Get.safelyToNamed('/');
            }))).showOnce();
  }

  // late void Function(dynamic) onReconnect;
  // static emptyOnReconnect(data) {
  //   print('onReconnect');
  //   print(data);
  // }

  // late void Function(dynamic) onReconnectAttempt;
  // static emptyOnReconnectAttempt(data) {
  //   print('onReconnectAttempt');
  //   print(data);
  // }

  // late void Function(dynamic) onReconnectFailed;
  // static emptyOnReconnectFailed(data) {
  //   print('onReconnectFailed');
  //   print(data);
  // }

  // late void Function(dynamic) onReconnectError;
  // static emptyOnReconnectError(data) {
  //   print('onReconnectError');
  //   print(data);
  // }

  // late void Function(dynamic) onReconnecting;
  // static emptyOnReconnecting(data) {
  //   print('onReconnecting');
  //   print(data);
  // }
  // void Function()? onPing;
  // void Function()? onPong;
}
