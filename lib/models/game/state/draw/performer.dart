part of 'draw.dart';

mixin _PerformerMixin on DrawStateMixin {
  String get word => data['word'];

  @override
  Future<void> onStart(Duration sinceStartDate) async {
    Get.find<GameClockController>().start(
        Duration(seconds: Game.inst.settings['draw_time']) - sinceStartDate,
        onEnd: () => SocketIO.inst.socket.emit('end_draw_state'));

    DrawManager.inst.reset();
  }

  @override
  Widget get canvas => const DrawWidget();

  @override
  Widget get status => const _WordIndicatorStatus();

  /// performer can't send messages to server
  @override
  void Function(String) get submitMessage => (_) {};
}

class _PerformerDrawState extends GameState with DrawStateMixin, _PerformerMixin {
  _PerformerDrawState({required super.data});
}

class _EmittingPerformerDrawState extends GameState with DrawStateMixin, _PerformerMixin {
  _EmittingPerformerDrawState({required super.data});

  int get revealedHintCount => RegExp(r'[^\s_]').allMatches(hint).length;

  int get hintCap => Game.inst.settings['hints'];
  set hint(String value) => data['hint'] = value;

  /// in seconds
  double get hintDuration => Game.inst.settings['draw_time'] / (hintCap + 1);

  Timer? timer;

  @override
  Future<void> onStart(Duration sinceStartDate) async {
    super.onStart(sinceStartDate);

    // state.hint, sinceStartDate
    // duration = drawTime / (settings.hint +1)
    // remaining hint = settings.hint - state.hint

    if (hintCap == revealedHintCount) return;

    timer = Timer(
        Duration(
            milliseconds: (hintDuration * (revealedHintCount + 1) * 1000).toInt() -
                sinceStartDate.inMilliseconds),
        revealRandomCharacter);
  }

  @override
  Future<Duration> onEnd(Duration sinceEndDate) {
    timer?.cancel();
    return super.onEnd(sinceEndDate);
  }

  void revealRandomCharacter() {
    var rand = math.Random();
    late int charIndex;
    do {
      charIndex = rand.nextInt(hint.length);
    } while (hint[charIndex] != '_');

    hint = hint.replaceRange(charIndex, charIndex + 1, word[charIndex]);

    // emit
    SocketIO.inst.socket.emit('hint', charIndex);

    if (hintCap == revealedHintCount) return;
    timer = Timer(Duration(milliseconds: (hintDuration * 1000).toInt()), revealRandomCharacter);
  }
}
