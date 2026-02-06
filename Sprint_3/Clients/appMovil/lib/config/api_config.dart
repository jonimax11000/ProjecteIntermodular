import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConfig {
  static Map<String, String> get urls {
    if (kIsWeb) {
      return {
        "login": "https://localhost:8069/api/authenticate",
        "cataleg": "https://localhost:8081/api/cataleg",
        "catalegBySeries": "https://localhost:8081/api/catalegBySerie/:id",
        "catalegByName": "https://localhost:8081/api/catalegByName/:name",
        "video": "https://localhost:3000/api",
        "series": "https://localhost:8081/api/series",
        "seriesByName": "https://localhost:8081/api/seriesByName/:name",
        "categorias": "https://localhost:8081/api/categories",
        "register": "https://localhost:8069/web/signup",
        "refreshAccess": "https://localhost:8069/api/update/access-token",
        "rotateRefresh": "https://localhost:8069/api/update/refresh-token"
      };
    }

    if (Platform.isAndroid) {
      return {
        "login": "https://172.20.10.8:8069/api/authenticate",
        "cataleg": "https://172.20.10.8:8081/api/cataleg",
        "catalegBySeries": "https://172.20.10.8:8081/api/catalegBySerie/:id",
        "catalegByName": "https://172.20.10.8:8081/api/catalegByName/:name",
        "video": "https://172.20.10.8:3000/api",
        "series": "https://172.20.10.8:8081/api/series",
        "seriesByName": "https://172.20.10.8:8081/api/seriesByName/:name",
        "categorias": "https://172.20.10.8:8081/api/categories",
        "register": "https://172.20.10.8:8069/web/signup",
        "refreshAccess": "https://172.20.10.8:8069/api/update/access-token",
        "rotateRefresh": "https://172.20.10.8:8069/api/update/refresh-token"
      };
    }

    return {
      "login": "https://172.20.10.8:8069/api/authenticate",
      "cataleg": "https://172.20.10.8:8081/api/cataleg",
      "catalegBySeries": "https://172.20.10.8:8081/api/catalegBySerie/:id",
      "catalegByName": "https://172.20.10.8:8081/api/catalegByName/:name",
      "video": "https://172.20.10.8:3000/api",
      "series": "https://172.20.10.8:8081/api/series",
      "seriesByName": "https://172.20.10.8:8081/api/seriesByName/:name",
      "categorias": "https://172.20.10.8:8081/api/categories",
      "register": "https://172.20.10.8:8069/web/signup",
      "refreshAccess": "https://172.20.10.8:8069/api/update/access-token",
      "rotateRefresh": "https://172.20.10.8:8069/api/update/refresh-token"
    };
  }
}
