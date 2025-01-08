import 'dart:convert';

import 'package:http/http.dart';

class API {
  API._internal();
  static final API _instance = API._internal();
  static API get inst => _instance;
  final client = Client();
  final String uri = 'http://127.0.0.1:4000/';
  Future<Response> get(String smt) async {
    return client.get(Uri.parse('$uri$smt'));
  }

  Future<Response> post(String path, Map<String, dynamic> data) async {
    return client.post(Uri.parse('$uri$path'),
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});
  }
}
