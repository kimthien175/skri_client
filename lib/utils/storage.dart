import 'dart:convert';
import 'package:web/web.dart' as web;

class Storage {
  static String get _key => 'smt';
  static Map<String, dynamic> get data {
    String? smt = web.window.localStorage.getItem(_key);
    if (smt == null) {
      Storage.data = {};
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
    Storage.data = data;
  }

  static set data(Map<String, dynamic> value) {
    web.window.localStorage.setItem(_key, jsonEncode(value));
  }
}
