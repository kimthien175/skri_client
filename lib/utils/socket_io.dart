import 'package:cd_mobile/models/game/game.dart';
import 'package:cd_mobile/models/game/player.dart';
import 'package:cd_mobile/utils/api.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketIO {
  SocketIO._internal() {
    _socket =
        io(API.inst.uri, OptionBuilder().setTransports(['websocket']).disableAutoConnect().build());

    eventHandlers = SessionEventHandlers.initWithSocket(socket: socket);

    _socket.on('player_join', (newPlayerEmit) {
      var inst = Game.inst;
      var newPlayer = Player.fromJSON(newPlayerEmit['player']);
      inst.playersByList.add(newPlayer);
      inst.playersByMap[newPlayer.id] = newPlayer;

      inst.addMessage(newPlayerEmit['message']);
    });

    _socket.on('player_leave', onPlayerLeave);

    _socket.on('new_host', onNewHost);

    _socket.on('host_leave', (hostLeaveEmit) {
      onPlayerLeave(hostLeaveEmit[0]);
      onNewHost(hostLeaveEmit[1]);
    });


  }
  static final SocketIO _inst = SocketIO._internal();

  static SocketIO get inst => _inst;

  late final Socket _socket;
  Socket get socket => _socket;

  late final SessionEventHandlers eventHandlers;

  onPlayerLeave(dynamic playerLeaveEmit) {
    var leftPlayerId = playerLeaveEmit['player_id'];
    // player list side
    var inst = Game.inst;
    inst.playersByList.removeWhere((element) => element.id == leftPlayerId);

    // message side
    inst.addMessage(playerLeaveEmit);

    inst.playersByMap.removeWhere((key, value) => key == leftPlayerId);
  }

  onNewHost(dynamic newHostEmit){
    var inst  = Game.inst;
    var newHost = inst.playersByMap[newHostEmit['player_id']]!;
    newHost.isOwner = true;
    inst.playersByList.refresh();

    inst.addMessage(newHostEmit);

    if (MePlayer.inst.isOwner){
      // i am new host
      print('i am new host');
    }
  }
}

class SessionEventHandlers {
  SessionEventHandlers.initWithSocket({
    required Socket socket,
    Function(dynamic)? onConnect,
    Function(dynamic)? onConnectError,
    Function(dynamic)? onConnectTimeout,
    Function(dynamic)? onConnecting,
    Function(dynamic)? onDisconnect,
    Function(dynamic)? onError,
    Function(dynamic)? onReconnect,
    Function(dynamic)? onReconnectAttempt,
    Function(dynamic)? onReconnectFailed,
    Function(dynamic)? onReconnectError,
    Function(dynamic)? onReconnecting,
  }) {
    this.onConnect = onConnect ?? emptyOnConnect;
    socket.onConnect((data) => this.onConnect(data));

    this.onConnectError = onConnectError ?? emptyOnConnectError;
    socket.onConnectError((data) => this.onConnectError(data));

    this.onConnectTimeout = onConnectTimeout ?? emptyOnConnectTimeout;
    socket.onConnectTimeout((data) => this.onConnectTimeout(data));

    this.onConnecting = onConnecting ?? emptyOnConnecting;
    socket.onConnecting((data) => this.onConnecting(data));

    this.onDisconnect = onDisconnect ?? emptyOnDisconnect;
    socket.onDisconnect((data) => this.onDisconnect(data));

    this.onError = onError ?? emptyOnError;
    socket.onError((data) => this.onError(data));

    this.onReconnect = onReconnect ?? emptyOnReconnect;
    socket.onReconnect((data) => this.onReconnect(data));

    this.onReconnectAttempt = onReconnectAttempt ?? emptyOnReconnectAttempt;
    socket.onReconnectAttempt((data) => this.onReconnectAttempt(data));

    this.onReconnectFailed = onReconnectFailed ?? emptyOnReconnectFailed;
    socket.onReconnectFailed((data) => this.onReconnectFailed(data));

    this.onReconnectError = onReconnectError ?? emptyOnReconnectError;
    socket.onReconnectError((data) => this.onReconnectError(data));

    this.onReconnecting = onReconnecting ?? emptyOnReconnecting;
    socket.onReconnecting((data) => this.onReconnecting(data));
  }
  late void Function(dynamic) onConnect;
  static emptyOnConnect(data) {
    print('onConnect');
    print(data);
  }

  late void Function(dynamic) onConnectError;
  static emptyOnConnectError(data) {
    print('onConnectionError');
    print(data);
  }

  late void Function(dynamic) onConnectTimeout;
  static emptyOnConnectTimeout(data) {
    print('onConnectTimeout');
    print(data);
  }

  late void Function(dynamic) onConnecting;
  static emptyOnConnecting(data) {
    print('onConnecting');
    print(data);
  }

  late void Function(dynamic) onDisconnect;
  static emptyOnDisconnect(data) {
    print('onDisconnect');
    print(data);
  }

  late void Function(dynamic) onError;
  static emptyOnError(data) {
    print('onError');
    print(data);
  }

  late void Function(dynamic) onReconnect;
  static emptyOnReconnect(data) {
    print('onReconnect');
    print(data);
  }

  late void Function(dynamic) onReconnectAttempt;
  static emptyOnReconnectAttempt(data) {
    print('onReconnectAttempt');
    print(data);
  }

  late void Function(dynamic) onReconnectFailed;
  static emptyOnReconnectFailed(data) {
    print('onReconnectFailed');
    print(data);
  }

  late void Function(dynamic) onReconnectError;
  static emptyOnReconnectError(data) {
    print('onReconnectError');
    print(data);
  }

  late void Function(dynamic) onReconnecting;
  static emptyOnReconnecting(data) {
    print('onReconnecting');
    print(data);
  }
  // void Function()? onPing;
  // void Function()? onPong;
}
