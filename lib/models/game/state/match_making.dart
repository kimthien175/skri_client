import 'package:skribbl_client/models/game/state/state.dart';

class MatchMakingState extends GameState {
  MatchMakingState({required super.data});

  @override
  Future<DateTime> onEnd(DateTime endDate) {
    // TODO: implement onEnd
    throw UnimplementedError();
  }

  @override
  Future<DateTime> onStart(DateTime date) {
    // TODO: implement onStart
    throw UnimplementedError();
  }

  @override
  void onClose() {}
}
