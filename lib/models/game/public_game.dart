import 'package:skribbl_client/models/models.dart';

class PublicGame extends Game {
  PublicGame._internal({required super.data});
  static PublicGame load({required Map<String, dynamic> room}) => PublicGame._internal(data: room);

  static void join() async {
    Game.connect('join_public_match', Game.requestRoomPackage, PublicGame.load);
  }
}
