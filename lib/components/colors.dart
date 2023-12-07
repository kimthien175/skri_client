import 'package:cd_mobile/utils/settings.dart';
import 'package:flutter/material.dart';

class AssetColors {
  static final Map<String, Color> _colors = {};
  static Color get(String name) {
    var result = _colors[name];
    if (result == null) {
      var info = Settings.inst.get(name);
      var color = Color.fromRGBO(info['r'], info['g'], info['b'], info['a'] ?? 1);
      _colors[name] = color;
      return color;
    } else {
      return result;
    }
  }
}
