import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/kiwoom_credentials_model.dart';

/// 키움 REST API 응답 모델
class KiwoomResponse {
  final int statusCode;
  final Map<String, dynamic> body;
  final String? contYn;
  final String? nextKey;

  KiwoomResponse({
    required this.statusCode,
    required this.body,
    this.contYn,
    this.nextKey,
  });

  bool get isSuccess => statusCode == 200;
  bool get hasNext => contYn == 'Y' && nextKey != null && nextKey!.isNotEmpty;
}

/// 인증과 공통 HTTP 호출을 담당하는 키움 API 클라이언트
class KiwoomApiClient {
  static const String exchangeKrx = 'KRX';
  static const String queryTypeDetail = '2';

  KiwoomCredentials? _credentials;

  void setCredentials(KiwoomCredentials credentials) {
    _credentials = credentials;
  }

  KiwoomCredentials? get credentials => _credentials;

  String get baseUrl => _credentials?.baseUrl ?? 'https://api.kiwoom.com';

  bool get hasValidToken => _credentials?.hasValidToken ?? false;

  Future<KiwoomResponse> issueToken(KiwoomCredentials credentials) async {
    final url = Uri.parse('${credentials.baseUrl}/oauth2/token');
    final headers = {'Content-Type': 'application/json;charset=UTF-8'};
    final body = jsonEncode({
      'grant_type': 'client_credentials',
      'appkey': credentials.appKey,
      'secretkey': credentials.appSecret,
    });

    debugPrint('Kiwoom API: Issuing token to ${credentials.baseUrl}');
    final response = await http.post(url, headers: headers, body: body);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && responseBody['token'] != null) {
      credentials.accessToken = responseBody['token'] as String;
      credentials.tokenExpiry = DateTime.now().add(const Duration(hours: 23));
      await KiwoomCredentials.save(credentials);
      _credentials = credentials;
    }

    return KiwoomResponse(statusCode: response.statusCode, body: responseBody);
  }

  Future<KiwoomResponse> callApi({
    required String endpoint,
    required String apiId,
    Map<String, dynamic> params = const {},
    String contYn = 'N',
    String nextKey = '',
  }) async {
    if (_credentials == null || _credentials!.accessToken == null) {
      return KiwoomResponse(
        statusCode: 401,
        body: {'error': '인증 토큰이 없습니다.'},
      );
    }

    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json;charset=UTF-8',
      'authorization': 'Bearer ${_credentials!.accessToken}',
      'cont-yn': contYn,
      'next-key': nextKey,
      'api-id': apiId,
    };

    debugPrint('Kiwoom API Call: $apiId ($endpoint)');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(params),
    );
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

    debugPrint('Kiwoom API Response: $apiId Status ${response.statusCode}');

    return KiwoomResponse(
      statusCode: response.statusCode,
      body: responseBody,
      contYn: response.headers['cont-yn'],
      nextKey: response.headers['next-key'],
    );
  }

  Future<bool> authenticate(KiwoomCredentials credentials) async {
    try {
      final response = await issueToken(credentials);
      return response.isSuccess && hasValidToken;
    } catch (_) {
      return false;
    }
  }

  Future<bool> ensureToken(KiwoomCredentials credentials) async {
    if (hasValidToken) return true;
    return authenticate(credentials);
  }

  void clearToken() {
    _credentials?.accessToken = null;
    _credentials?.tokenExpiry = null;
  }
}
