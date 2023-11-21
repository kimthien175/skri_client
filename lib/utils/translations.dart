import 'package:cd_mobile/utils/read_json.dart';
import 'package:get/get.dart';

class GameTranslations extends Translations {
  //#region Singleton
  GameTranslations._internal();
  static final GameTranslations _inst = GameTranslations._internal();
  static GameTranslations inst() => GameTranslations._inst;
  //#endregion

  // ignore: prefer_final_fields, prefer_collection_literals
  late Map<String, Map<String, String>> _keys = Map();
  init() async {
    Map raw = await readJSON('assets/translations/translations.json');

    raw.forEach((key, value) {
      _keys[key] = Map<String, String>.from(value);
    });
  }

  @override
  Map<String, Map<String, String>> get keys => _keys;
}
