import 'package:cd_mobile/utils/read_json.dart';

class Settings{
  //#region Singleton
  Settings._internal();
  static final Settings _inst = Settings._internal();
  static Settings get inst=>_inst;
  //#endregion

  Map<String, dynamic> _content = {};

  Future<void> load() async {
    _content = await readJSON('assets/settings.json');
  }

  dynamic get(String key){
    return _content[key];
  }
}