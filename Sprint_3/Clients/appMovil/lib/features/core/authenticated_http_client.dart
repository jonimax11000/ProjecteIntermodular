import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'session_service.dart';

/// Cliente HTTP que maneja automáticamente la renovación de tokens
/// cuando recibe errores 401 (Unauthorized)
class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner;
  final SessionService _sessionService;

  // Para evitar múltiples renovaciones simultáneas
  Future<void>? _refreshInProgress;

  AuthenticatedHttpClient({
    http.Client? innerClient,
    SessionService? sessionService,
  })  : _inner = innerClient ?? http.Client(),
        _sessionService =
            sessionService ?? SessionService(const FlutterSecureStorage());

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Asegurar que tenemos un token válido antes de enviar la petición
    final token = await _sessionService.ensureValidAccessToken();

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Añadir refresh token para que el backend pueda renovar si es necesario
    final refreshToken = await _sessionService.getRefreshToken();
    print('🔄 Refresh token: $refreshToken');
    if (refreshToken != null) {
      request.headers['refresh-token'] = refreshToken;
    }

    print('🔄 Request headers: ${request.headers}');

    // Enviar la petición original
    var response = await _inner.send(request);

    // Si recibimos 401, intentar renovar el token y reintentar UNA vez
    if (response.statusCode == 401) {
      print('🔄 Received 401, attempting token refresh...');

      try {
        // Renovar el token
        await _refreshTokenIfNeeded();

        // Obtener el nuevo token
        final newToken = await _sessionService.getAccessToken();

        if (newToken != null) {
          // Crear una nueva petición con el token actualizado
          final newRequest = _copyRequest(request);
          newRequest.headers['Authorization'] = 'Bearer $newToken';

          print('✅ Retrying request with new token...');
          response = await _inner.send(newRequest);
        }
      } catch (e) {
        print('❌ Token refresh failed: $e');
        // Si falla la renovación, devolvemos la respuesta 401 original
      }
    }

    return response;
  }

  /// Renueva el token evitando llamadas duplicadas
  Future<void> _refreshTokenIfNeeded() async {
    // Si ya hay una renovación en progreso, esperar a que termine
    if (_refreshInProgress != null) {
      print('⏳ Token refresh already in progress, waiting...');
      await _refreshInProgress;
      return;
    }

    // Iniciar nueva renovación
    _refreshInProgress = _sessionService.refreshAccessToken();

    try {
      await _refreshInProgress;
      print('✅ Token refreshed successfully');
    } finally {
      _refreshInProgress = null;
    }
  }

  /// Copia una petición HTTP (necesario porque BaseRequest no se puede reutilizar)
  http.BaseRequest _copyRequest(http.BaseRequest request) {
    http.BaseRequest newRequest;

    if (request is http.Request) {
      newRequest = http.Request(request.method, request.url)
        ..bodyBytes = request.bodyBytes;
    } else if (request is http.MultipartRequest) {
      newRequest = http.MultipartRequest(request.method, request.url)
        ..fields.addAll(request.fields)
        ..files.addAll(request.files);
    } else if (request is http.StreamedRequest) {
      throw Exception('Cannot retry streamed requests');
    } else {
      throw Exception('Unknown request type');
    }

    newRequest
      ..persistentConnection = request.persistentConnection
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..headers.addAll(request.headers);

    return newRequest;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
