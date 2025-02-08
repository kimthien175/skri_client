import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

class Storage {
  static String get _key => 'smt';
  static Map<String, dynamic> get data {
    String? smt = window.localStorage[_key];
    if (smt == null) {
      window.localStorage[_key] = '{}';
      return {};
    }
    return jsonDecode(smt);
  }

  static void set(List<String> keys, dynamic value) {
    var data = Storage.data;
    dynamic subData = data;

    for (int i = 0; i < keys.length - 1; i++) {
      if (subData[keys[i]] == null) {
        subData[keys[i]] = {};
      }
      subData = subData[keys[i]];
    }

    subData[keys.last] = value;
    window.localStorage[_key] = jsonEncode(data);
  }

  static set data(Map<String, dynamic> value) {
    window.localStorage[_key] = jsonEncode(value);
  }
}
