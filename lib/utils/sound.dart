import 'package:flutter/services.dart';
import 'package:skribbl_client/pages/gameplay/widgets/game_bar/settings/settings.dart';
import 'package:soundpool/soundpool.dart';

class Sound {
  static final Sound _inst = Sound._internal();
  static Sound get inst => _inst;
  Sound._internal() {
    // load assets
    _pool = Soundpool.fromOptions(options: SoundpoolOptions.kDefault);
  }

  Future<void> load() async {
    _tick = await rootBundle.load("assets/sound/tick.ogg").then((data) => _pool.load(data));
    _join = await rootBundle.load('assets/sound/join.ogg').then((data) => _pool.load(data));
    _leave = await rootBundle.load('assets/sound/leave.ogg').then((data) => _pool.load(data));
    _guessedRight =
        await rootBundle.load('assets/sound/playerGuessed.ogg').then((data) => _pool.load(data));
    _roundEndFailure =
        await rootBundle.load('assets/sound/roundEndFailure.ogg').then((data) => _pool.load(data));
    _roundEndSuccess =
        await rootBundle.load('assets/sound/roundEndSuccess.ogg').then((data) => _pool.load(data));
    _roundStart =
        await rootBundle.load('assets/sound/roundStart.ogg').then((data) => _pool.load(data));
    setVolume(SystemSettings.inst.volume);
  }

  late final Soundpool _pool;
  Future<void> Function(int) get play => _pool.play;
  Future<void> Function(int) get stop => _pool.stop;

  late final int _tick;
  int get tick => _tick;

  late final int _join;
  int get join => _join;

  late final int _leave;
  int get leave => _leave;

  late final int _guessedRight;
  int get guessedRight => _guessedRight;

  late final int _roundEndFailure;
  int get roundEndFailure => _roundEndFailure;

  late final int _roundEndSuccess;
  int get roundEndSuccess => _roundEndSuccess;

  late final int _roundStart;
  int get roundStart => _roundStart;

  void setVolume(double value) {
    _pool.setVolume(soundId: tick, volume: value);
    _pool.setVolume(soundId: join, volume: value);
    _pool.setVolume(soundId: leave, volume: value);
    _pool.setVolume(soundId: guessedRight, volume: value);
    _pool.setVolume(soundId: roundEndFailure, volume: value);
    _pool.setVolume(soundId: roundEndSuccess, volume: value);
    _pool.setVolume(soundId: roundStart, volume: value);
  }
}
