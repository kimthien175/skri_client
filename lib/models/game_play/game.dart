import 'package:cd_mobile/models/game_play/player.dart';

abstract class Game<GAME_TYPE extends Game<GAME_TYPE>> {
  Game(this.players);
  static Game? _inst;
  static Game get inst => _inst!;

  List<Player> players;

  static initPrivateRoom() {
    _inst = PrivateGame.init();
  }
}

class PrivateGame extends Game<PrivateGame> {
  PrivateGame(super.players);
  static PrivateGame init() {
    // set up MePlayer
    var me = MePlayer.inst;
    me.isOwner = true;
    me.processName();

    return PrivateGame([me]);
  }

  dynamic settings = {};
}
