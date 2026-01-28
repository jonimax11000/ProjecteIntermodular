import 'dart:io';
import 'package:http/io_client.dart';

class ApiClient {
  static IOClient? _client;
  static IOClient get client {
    if (_client == null) {
      final httpClient = HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      _client = IOClient(httpClient);
    }
    return _client!;
  }

  static void dispose() {
    _client?.close();
    _client = null;
  }
}
