// ignore_for_file: constant_identifier_names

abstract class GameState {
  GameState({this.cachedNextState, required this.startedDate});
  //.factory GameState.fromJSON(Map<String, dynamic> data) {}

  static const prevGame = 'prev_game';
  static const chooseWord = 'choose_word';
  static const draw = 'draw';
  static const gameResult = 'gameResult';

  static const matchMaking = 'match_making';

  /// close current state and switch to next state
  void next() {}

  void start();
  Future<void> end();

  GameState? cachedNextState;
  String startedDate;
}
