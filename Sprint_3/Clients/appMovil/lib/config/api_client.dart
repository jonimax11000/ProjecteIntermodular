import 'dart:convert';
import 'package:exercici_disseny_responsiu_stateful/config/api_config.dart';
import 'package:exercici_disseny_responsiu_stateful/features/core/session_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final SessionService _session = SessionService(const FlutterSecureStorage());

  // ================= HEADERS =================

  Future<Map<String, String>> _authorizedHeaders() async {
    await _refreshIfNeeded();

    final token = await _session.getAccessToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ================= REFRESH =================

  Future<void> _refreshIfNeeded() async {
    final expired = await _session.isAccessExpired();
    if (!expired) return;

    print("TOKEN EXPIRADO → REFRESH");

    final refreshToken = await _session.getRefreshToken();
    final userId = await _session.getUserId();

    if (refreshToken == null || userId == null) {
      await _session.clearSession();
      throw Exception("Session expired");
    }

    final response = await http.post(
      Uri.parse(ApiConfig.urls["refreshAccess"]!),
      headers: {
        'Content-Type': 'application/json',
        'refreshToken': refreshToken,
      },
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode != 200) {
      await _session.clearSession();
      throw Exception("Refresh failed");
    }

    final data = jsonDecode(response.body);
    final newAccessToken = data['access_token'];

    await _session.saveSession(
      accessToken: newAccessToken,
      refreshToken: refreshToken,
      userId: userId,
    );
  }

  // ================= REQUESTS =================

  Future<http.Response> get(String url) async {
    final headers = await _authorizedHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> post(String url, {Map<String, dynamic>? body}) async {
    final headers = await _authorizedHeaders();
    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body ?? {}),
    );
  }
}
