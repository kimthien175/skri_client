import 'dart:convert';
import 'package:flutter/services.dart';

Future<dynamic> readJSON(String filePath) async {
  String result = await rootBundle.loadString(filePath);
  return jsonDecode(result);
}