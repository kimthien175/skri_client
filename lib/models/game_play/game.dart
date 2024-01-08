import 'package:cd_mobile/models/game_play/player.dart';

class Game{
  Game._internal();
  static Game? _inst;
  static Game get inst=>_inst!;
  static init(){
    _inst = Game._internal();
  }

  List<Player> players=[];

  setWinner(){}
  Player? winner;
}