import 'package:cd_mobile/utils/api.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketIO {
  SocketIO._internal() {
    print('init socket');
    _socket =
        io(API.inst.uri, OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());

    _socket.onConnect((data) {
      print('connect');
      _socket.emit('msg', 'test');
    });

    _socket.on('event', (data) => print(data));
    _socket.onDisconnect((data) => print('disconnect'));
    _socket.on('fromServer', (_) => print(_));
  }
  static final SocketIO _instance = SocketIO._internal();
  static SocketIO get inst => _instance;

  late final Socket _socket;

  void connect(){
    _socket.connect();
  }
}
