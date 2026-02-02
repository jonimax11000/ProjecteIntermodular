import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConfig {
  static Map<String, String> get urls {
    if (kIsWeb) {
      return {
        "login": "https://localhost:8069/api/authenticate",
        "cataleg": "https://localhost:8081/api/cataleg",
        "catalegBySeries": "https://localhost:8081/api/catalegBySeries/:id",
        "catalegByName": "https://localhost:8081/api/catalegByName/:name",
        "video": "https://localhost:3000/api",
        "series": "https://localhost:8081/api/series",
        "seriesByName": "https://localhost:8081/api/seriesByName/:name",
        "categorias": "https://localhost:8081/api/categories",
      };
    }

    if (Platform.isAndroid) {
      return {
        "login": "https://10.0.2.2:8069/api/authenticate",
        "cataleg": "https://10.0.2.2:8081/api/cataleg",
        "catalegBySeries": "https://10.0.2.2:8081/api/catalegBySeries/:id",
        "catalegByName": "https://10.0.2.2:8081/api/catalegByName/:name",
        "video": "https://10.0.2.2:3000/api",
        "series": "https://10.0.2.2:8081/api/series",
        "seriesByName": "https://10.0.2.2:8081/api/seriesByName/:name",
        "categorias": "https://10.0.2.2:8081/api/categories",
      };
    }

    return {
      "login": "https://10.0.2.2:8069/api/authenticate",
      "cataleg": "https://10.0.2.2:8081",
      "catalegBySeries": "https://10.0.2.2:8081/api/catalegBySeries/:id",
      "catalegByName": "https://10.0.2.2:8081/api/catalegByName/:name",
      "video": "https://10.0.2.2:3000/api",
      "series": "https://10.0.2.2:8081/api/series",
      "seriesByName": "https://10.0.2.2:8081/api/seriesByName/:name",
      "categorias": "https://10.0.2.2:8081/api/categories",
    };
  }
}
