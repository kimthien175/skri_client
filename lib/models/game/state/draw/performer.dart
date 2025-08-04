part of 'draw.dart';

mixin _PerformerMixin on _DrawStateMixin {
  String get word => data['word'];

  @override
  Future<void> onStart(Duration sinceStartDate) async {
    super.onStart(sinceStartDate);

    DrawManager.inst.reset();
  }

  @override
  Widget get canvas => const DrawWidget();

  @override
  Widget get status => const _WordIndicatorStatus();
}

class _PerformerDrawState extends GameState with _DrawStateMixin, _PerformerMixin {
  _PerformerDrawState({required super.data});
}

class _EmittingPerformerDrawState extends GameState with _DrawStateMixin, _PerformerMixin {
  _EmittingPerformerDrawState({required super.data});

  int get revealedHintCount => RegExp(r'[^\s_]').allMatches(hint).length;

  int get hintCap => Game.inst.settings['hints'];
  set hint(String value) => data['hint'] = value;

  /// in seconds
  double get hintDuration => Game.inst.settings['draw_time'] / (hintCap + 1);

  late Timer timer;

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

    loopRandomizingCharacterWithHintDuration();
  }

  @override
  Future<Duration> onEnd(Duration sinceEndDate) {
    timer.cancel();
    return super.onEnd(sinceEndDate);
  }

  void loopRandomizingCharacterWithHintDuration() {
    if (hintCap == revealedHintCount) return;

    timer = Timer(Duration(milliseconds: (hintDuration * 1000).toInt()), () {
      revealRandomCharacter();
      loopRandomizingCharacterWithHintDuration();
    });
  }

  void revealRandomCharacter() {
    var rand = Random();
    late int charIndex;
    do {
      charIndex = rand.nextInt(hint.length);
    } while (hint[charIndex] != '_');

    hint = hint.replaceRange(charIndex, charIndex + 1, word[charIndex]);

    // emit
    SocketIO.inst.socket.emit('hint', charIndex);
  }
}
