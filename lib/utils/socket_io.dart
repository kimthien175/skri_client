import 'package:cd_mobile/utils/api.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketIO {
  SocketIO._internal() {
    _socket =
        io(API.inst.uri, OptionBuilder().setTransports(['websocket']).disableAutoConnect().build());

    eventHandlers = SessionEventHandlers.initWithSocket(socket: socket);
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
    this.onConnect = onConnect ??
        (data) {
          print('onConnect');
          print(data);
        };
    socket.onConnect((data) => this.onConnect(data));

    this.onConnectError = onConnectError ??
        (data) {
          print('onConnectionError');
          print(data);
        };
    socket.onConnectError((data) => this.onConnectError(data));

    this.onConnectTimeout = onConnectTimeout ??
        (data) {
          print('onConnectTimeout');
          print(data);
        };
    socket.onConnectTimeout((data) => this.onConnectTimeout(data));

    this.onConnecting = onConnecting ??
        (data) {
          print('onConnecting');
          print(data);
        };

    socket.onConnecting((data) => this.onConnecting(data));

    this.onDisconnect = onDisconnect ??
        (data) {
          print('onDisconnect');
          print(data);
        };

    socket.onDisconnect((data) => this.onDisconnect(data));

    this.onError = onError ??
        (data) {
          print('onError');
          print(data);
        };

    socket.onError((data) => this.onError(data));

    this.onReconnect = onReconnect ??
        (data) {
          print('onReconnect');
          print(data);
        };

    socket.onReconnect((data) => this.onReconnect(data));

    this.onReconnectAttempt = onReconnectAttempt ??
        (data) {
          print('onReconnectAttempt');
          print(data);
        };

    socket.onReconnectAttempt((data) => this.onReconnectAttempt(data));

    this.onReconnectFailed = onReconnectFailed ??
        (data) {
          print('onReconnectFailed');
          print(data);
        };

    socket.onReconnectFailed((data) => this.onReconnectFailed(data));

    this.onReconnectError = onReconnectError ??
        (data) {
          print('onReconnectError');
          print(data);
        };

    socket.onReconnectError((data) => this.onReconnectError(data));

    this.onReconnecting = onReconnecting ??
        (data) {
          print('onReconnecting');
          print(data);
        };

    socket.onReconnecting((data) => this.onReconnecting(data));
  }
  late void Function(dynamic) onConnect;
  late void Function(dynamic) onConnectError;
  late void Function(dynamic) onConnectTimeout;
  late void Function(dynamic) onConnecting;
  late void Function(dynamic) onDisconnect;
  late void Function(dynamic) onError;
  late void Function(dynamic) onReconnect;
  late void Function(dynamic) onReconnectAttempt;
  late void Function(dynamic) onReconnectFailed;
  late void Function(dynamic) onReconnectError;
  late void Function(dynamic) onReconnecting;
  // void Function()? onPing;
  // void Function()? onPong;
}
