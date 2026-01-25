import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SessionService {
  final FlutterSecureStorage _storage;

  SessionService(this._storage);

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'jwt');
  }

  Future<bool> isLoggedIn() async {
    return (await getToken()) != null;
  }

  Future<Map<String, dynamic>?> getTokenData() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      return JwtDecoder.decode(token);
    } catch (_) {
      return null;
    }
  }
}
