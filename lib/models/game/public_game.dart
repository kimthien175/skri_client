import 'game.dart';

// TODO: PUBLIC GAME
class PublicGame extends Game {
  PublicGame(
      {required super.currentRound,
      required super.rounds,
      //   required super.state,
      required super.playersByList,
      required super.roomCode,
      required super.settings});
  static void join() {}
}
