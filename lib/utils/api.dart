import 'dart:convert';

import 'package:http/http.dart';

class API {
  API._internal();
  static final API _instance = API._internal();
  static API get inst => _instance;
  final client = Client();
  String uri = const String.fromEnvironment('SERVER_URI');
  Future<Response> get(String smt) async {
    return client.get(Uri.parse('$uri$smt'));
  }

  Future<Response> post(String path, Map<String, dynamic> data) async {
    return client.post(Uri.parse('$uri$path'),
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});
  }
}
