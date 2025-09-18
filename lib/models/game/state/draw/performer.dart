part of 'draw.dart';

mixin _PerformerMixin on DrawStateMixin {
  String get word => data['word'];

  @override
  Future<DateTime> onStart(DateTime startDate) async {
    var drawDuration = Duration(seconds: Game.inst.settings['draw_time']) - startDate.fromNow();
    if (drawDuration > Duration.zero) {
      Get.find<GameClockController>()
          .start(drawDuration, onEnd: () => SocketIO.inst.socket.emit('end_draw_state'));
    }

    DrawManager.inst.reset();
    return startDate;
  }

  @override
  Widget get canvas => const DrawWidget();

  @override
  Widget get status => const _WordIndicatorStatus();

  /// performer can't send messages to server
  @override
  void Function(String) get submitMessage => (_) {};

  @override
  void onClose() {
    Get.find<GameClockController>().cancel();
  }
}

class PerformerDrawState extends GameState with DrawStateMixin, _PerformerMixin {
  PerformerDrawState({required super.data});
}

class EmittingPerformerDrawState extends GameState with DrawStateMixin, _PerformerMixin {
  EmittingPerformerDrawState({required super.data});

  int get revealedHintCount => RegExp(r'[^\s_]').allMatches(hint).length;

  late final int hintCap = min(Game.inst.settings['hints'], word.length - word.countSpaces - 1);
  set hint(String value) => data['hint'] = value;

  /// in seconds
  double get hintDuration => Game.inst.settings['draw_time'] / (hintCap + 1);

  Timer? timer;

  @override
  Future<DateTime> onStart(DateTime startDate) async {
    // state.hint, sinceStartDate
    // duration = drawTime / (settings.hint +1)
    // remaining hint = settings.hint - state.hint

    if (hintCap == revealedHintCount) return super.onStart(startDate);

    timer = Timer(
        Duration(
            milliseconds: (hintDuration * (revealedHintCount + 1) * 1000).toInt() -
                (DateTime.now() - startDate).inMilliseconds),
        revealRandomCharacter);

    return super.onStart(startDate);
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
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

    if (hintCap == revealedHintCount) return;
    timer = Timer(Duration(milliseconds: (hintDuration * 1000).toInt()), revealRandomCharacter);
  }
}

extension Spaces on String {
  int get countSpaces {
    var result = 0;
    for (var i = 0; i < length; i++) {
      if (this[i] == ' ') result++;
    }
    return result;
  }
}
