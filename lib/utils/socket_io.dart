import 'package:cd_mobile/models/game_play/game.dart';
import 'package:cd_mobile/utils/api.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketIO {
  SocketIO._internal() {
    _socket =
        io(API.inst.uri, OptionBuilder().setTransports(['websocket']).disableAutoConnect().build());

    eventHandlers = SessionEventHandlers.initWithSocket(socket: socket);

    _socket.on('message_from_server', (msg) {
      print(msg);
      Game.inst.addMessage(msg);
    });
  }
  static final SocketIO _inst = SocketIO._internal();

  static SocketIO get inst => _inst;

  late final Socket _socket;
  Socket get socket => _socket;

  late final SessionEventHandlers eventHandlers;
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
