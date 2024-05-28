// ignore_for_file: constant_identifier_names

class GameState{
  static GameState fromJSON(Map<String, dynamic> data){
    switch (data['type']){
      case '': 
        return GameState();
      default:
        throw Exception('Unhandled Case');
    }
  }

  static const setUp = 'set_up';
  static const startGame = 'start_game';
  static const draw='draw';
  static const drawResult_chooseWord = 'draw_result_choose_word';
  static const drawResult_startRound = 'draw_result_start_round';
  static const gameResult = 'gameResult';

  static const matchMaking = 'match_making';
}