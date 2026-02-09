import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:exercici_disseny_responsiu_stateful/features/core/authenticated_http_client.dart';
import 'package:exercici_disseny_responsiu_stateful/features/core/session_service.dart';

class ApiClient {
  static http.Client? _client;

  static http.Client get client {
    if (_client == null) {
      // 1. Crear el cliente base (IOClient) que ignora certificados SSL
      final httpClient = HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final ioClient = IOClient(httpClient);

      // 2. Envolverlo en AuthenticatedHttpClient
      _client = AuthenticatedHttpClient(
        innerClient: ioClient,
        sessionService: SessionService(const FlutterSecureStorage()),
      );
    }
    return _client!;
  }

  static void dispose() {
    _client?.close();
    _client = null;
  }
}
