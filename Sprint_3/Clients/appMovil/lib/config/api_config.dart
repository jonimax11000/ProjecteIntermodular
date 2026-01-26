import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConfig {
  static Map<String, String> get urls {
    if (kIsWeb) {
      return {
        "cataleg": "http://localhost:8081/api/cataleg",
        "catalegBySeries": "http://localhost:8081/api/catalegBySeries/:id",
        "catalegByName": "http://localhost:8081/api/catalegByName/:name",
        "video": "http://localhost:3000/api",
        "series": "http://localhost:8081/api/series",
        "seriesByName": "http://localhost:8081/api/seriesByName/:name",
        "categorias": "http://localhost:8081/api/categories",
      };
    }

    if (Platform.isAndroid) {
      return {
        "cataleg": "http://10.0.2.2:8081/api/cataleg",
        "catalegBySeries": "http://10.0.2.2:8081/api/catalegBySeries/:id",
        "catalegByName": "http://10.0.2.2:8081/api/catalegByName/:name",
        "video": "http://10.0.2.2:3000/api",
        "series": "http://10.0.2.2:8081/api/series",
        "seriesByName": "http://10.0.2.2:8081/api/seriesByName/:name",
        "categorias": "http://10.0.2.2:8081/api/categories",
      };
    }

    return {
      "cataleg": "http://localhost:8081",
      "catalegBySeries": "http://localhost:8081/api/catalegBySeries/:id",
      "catalegByName": "http://localhost:8081/api/catalegByName/:name",
      "video": "http://localhost:3000/api",
      "series": "http://localhost:8081/api/series",
      "seriesByName": "http://localhost:8081/api/seriesByName/:name",
      "categorias": "http://localhost:8081/api/categories",
    };
  }
}
