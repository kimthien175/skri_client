import 'dart:convert';
import 'package:flutter/services.dart';

Future<dynamic> readJSON(String filePath) async {
  var str = await rootBundle.loadString(filePath);
  return jsonDecode(str);
}