import 'package:cd_mobile/utils/api.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketIO {
  SocketIO._internal() {
    _socket =
        io(API.inst.uri, OptionBuilder().setTransports(['websocket']).disableAutoConnect().build());

    // _socket.onConnect((data) {
    //   print('connect');
    //   _socket.emitWithAck('msg', 'test', ack:(data){
    //     print(data);
    //   });
    // });

    // _socket.on('event', (data) => print(data));
    // _socket.onDisconnect((data) {
    //   showDialog(
    //       context: Get.context!,
    //       builder: (ct) =>
    //           AlertDialog(title: const Text("Disconnected"), content: Text(data.toString())));
    // });

    // _socket.on('fromServer', (data) => print(data));
    eventHandlers = SessionEventHandlers.initWithSocket(socket: socket);
  }
  static SocketIO? _inst = _init();

  /// called only once
  static SocketIO _init() {
    _inst = SocketIO._internal();
    _inst?.eventHandlers = SessionEventHandlers();

    return SocketIO._inst!;
  }

  static SocketIO get inst => _inst!;

  late final Socket _socket;
  Socket get socket => _socket;

  late SessionEventHandlers eventHandlers;
}

class SessionEventHandlers {
  SessionEventHandlers.initWithSocket({
    required Socket socket,
    this.onConnect,
    this.onConnectError,
    this.onConnectTimeout,
    this.onConnecting,
    this.onDisconnect,
    this.onError,
    this.onReconnect,
    this.onReconnectAttempt,
    this.onReconnectFailed,
    this.onReconnectError,
    this.onReconnecting,
  }) {
    socket.onConnect((data) {
      print('onConnect');
      print(data);
      if (onConnect != null) onConnect!();
    });

    socket.onConnectError((data) {
      print('onConnectionError');
      print(data);
      if (onConnectError != null) onConnectError!();
    });

    socket.onConnectTimeout((data) {
      print('onConnectTimeout');
      print(data);
      if (onConnectTimeout != null) onConnectTimeout!();
    });

    socket.onConnecting((data) {
      print('onConnecting');
      print(data);
      if (onConnecting != null) onConnecting!();
    });

    socket.onDisconnect((data) {
      print('onDisconnect');
      print(data);
      if (onDisconnect != null) onDisconnect!();
    });

    socket.onError((data) {
      print('onError');
      print(data);
      if (onError != null) onError!();
    });

    socket.onReconnect((data) {
      print('onReconnect');
      print(data);
      if (onReconnect != null) onReconnect!();
    });

    socket.onReconnectAttempt((data) {
      print('onReconnectAttempt');
      print(data);
      if (onReconnectAttempt != null) onReconnectAttempt!();
    });

    socket.onReconnectFailed((data) {
      print('onReconnectFailed');
      print(data);
      if (onReconnectFailed != null) onReconnectFailed!();
    });

    socket.onReconnectError((data) {
      print('onReconnectError');
      print(data);
      if (onReconnectError != null) onReconnectError!();
    });

    socket.onReconnecting((data) {
      print('onReconnecting');
      print(data);
      if (onReconnecting != null) onReconnecting!();
    });
  }
  SessionEventHandlers({
    this.onConnect,
    this.onConnectError,
    this.onConnectTimeout,
    this.onConnecting,
    this.onDisconnect,
    this.onError,
    this.onReconnect,
    this.onReconnectAttempt,
    this.onReconnectFailed,
    this.onReconnectError,
    this.onReconnecting,
    // this.onPing,
    // this.onPong
  }) {
    socket.onConnect((data) {
      print('onConnect');
      print(data);
      if (onConnect != null) onConnect!();
    });

    socket.onConnectError((data) {
      print('onConnectionError');
      print(data);
      if (onConnectError != null) onConnectError!();
    });

    socket.onConnectTimeout((data) {
      print('onConnectTimeout');
      print(data);
      if (onConnectTimeout != null) onConnectTimeout!();
    });

    socket.onConnecting((data) {
      print('onConnecting');
      print(data);
      if (onConnecting != null) onConnecting!();
    });

    socket.onDisconnect((data) {
      print('onDisconnect');
      print(data);
      if (onDisconnect != null) onDisconnect!();
    });

    socket.onError((data) {
      print('onError');
      print(data);
      if (onError != null) onError!();
    });

    socket.onReconnect((data) {
      print('onReconnect');
      print(data);
      if (onReconnect != null) onReconnect!();
    });

    socket.onReconnectAttempt((data) {
      print('onReconnectAttempt');
      print(data);
      if (onReconnectAttempt != null) onReconnectAttempt!();
    });

    socket.onReconnectFailed((data) {
      print('onReconnectFailed');
      print(data);
      if (onReconnectFailed != null) onReconnectFailed!();
    });

    socket.onReconnectError((data) {
      print('onReconnectError');
      print(data);
      if (onReconnectError != null) onReconnectError!();
    });

    socket.onReconnecting((data) {
      print('onReconnecting');
      print(data);
      if (onReconnecting != null) onReconnecting!();
    });
  }
  Socket get socket => SocketIO.inst.socket;
  void Function()? onConnect;
  void Function()? onConnectError;
  void Function()? onConnectTimeout;
  void Function()? onConnecting;
  void Function()? onDisconnect;
  void Function()? onError;
  void Function()? onReconnect;
  void Function()? onReconnectAttempt;
  void Function()? onReconnectFailed;
  void Function()? onReconnectError;
  void Function()? onReconnecting;
  // void Function()? onPing;
  // void Function()? onPong;
}
