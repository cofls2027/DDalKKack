import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app_config.dart';

class ApiClient {
  String? _accessToken;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  Uri buildUri(String path) => _uri(path);

  void addAuthHeader(Map<String, String> headers) {
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
  }
  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };
  }

  Uri _uri(String path) {
    final baseUrl = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/$'), '');
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await http.get(
      _uri(path),
      headers: _headers,
    );

    return _decodeObject(response);
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await http.get(
      _uri(path),
      headers: _headers,
    );

    return _decodeList(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );

    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> patchJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.patch(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );

    return _decodeObject(response);
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API 오류 ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('API 응답이 객체 형식이 아닙니다.');
  }

  List<dynamic> _decodeList(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API 오류 ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      return decoded['data'] as List;
    }

    throw Exception('API 응답이 리스트 형식이 아닙니다.');
  }
}

final apiClient = ApiClient();