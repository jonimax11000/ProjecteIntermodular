import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConfig {
  static Map<String, String> get urls {
    if (kIsWeb) {
      return {
        "cataleg": "http://localhost:8081/api/cataleg",
        "video": "http://localhost:3000/api",
        "series": "http://localhost:8081/api/series",
        "categorias": "http://localhost:8081/api/categories",
      };
    }

    if (Platform.isAndroid) {
      return {
        "cataleg": "http://10.0.2.2:8081/api/cataleg",
        "video": "http://10.0.2.2:3000/api",
        "series": "http://10.0.2.2:8081/api/series",
        "categorias": "http://10.0.2.2:8081/api/categories",
      };
    }

    return {
      "cataleg": "http://localhost:8081",
      "video": "http://localhost:3000/api",
      "series": "http://localhost:8081/api/series",
      "categorias": "http://localhost:8081/api/categories",
    };
  }
}
