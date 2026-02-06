import 'dart:convert';

import 'package:exercici_disseny_responsiu_stateful/config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class SessionService {
  final FlutterSecureStorage _storage;

  SessionService(this._storage);

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  // ---------- SAVE ----------
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required int userId,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
    await _storage.write(key: _userIdKey, value: userId.toString());
  }

  // ---------- GET ----------
  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<int?> getUserId() async {
    final id = await _storage.read(key: _userIdKey);
    return id != null ? int.parse(id) : null;
  }

  // ---------- REMOVE ----------
  Future<void> clearSession() async {
    await _storage.deleteAll();
  }

  // ---------- CHECK EXP ----------
  Future<bool> isAccessExpired() async {
    final token = await getAccessToken();
    if (token == null) return true;
    return JwtDecoder.isExpired(token);
  }

  Future<Map<String, dynamic>?> getAccessTokenData() async {
    final token = await getAccessToken();
    if (token == null) return null;

    try {
      return JwtDecoder.decode(token);
    } catch (_) {
      return null;
    }
  }

  Future<String?> ensureValidAccessToken() async {
    if (await isAccessExpired()) {
      await refreshAccessToken(); // esto llama a tu endpoint refresh
    }
    return await getAccessToken();
  }

  Future<void> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    final userId = await getUserId();
    if (refreshToken == null || userId == null) {
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

    if (response.statusCode != 200) throw Exception("Refresh failed");

    final data = jsonDecode(response.body);
    final newAccessToken = data['access_token'];

    await saveSession(
      accessToken: newAccessToken,
      refreshToken: refreshToken,
      userId: userId,
    );
  }

  Future<void> rotateRefreshToken() async {
    final refreshToken = await getRefreshToken();
    final userId = await getUserId();

    if (refreshToken == null || userId == null) {
      throw Exception("No refresh token or user ID available");
    }

    final response = await http.post(
      Uri.parse(ApiConfig.urls["rotateRefresh"]!),
      headers: {
        'Content-Type': 'application/json',
        'refreshToken': refreshToken,
      },
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to rotate refresh token");
    }

    final data = jsonDecode(response.body);

    if (data['status'] != 'done') {
      throw Exception("Refresh token rotation not completed");
    }

    print("Refresh token rotated successfully");
  }
}
