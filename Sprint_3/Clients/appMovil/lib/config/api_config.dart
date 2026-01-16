import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConfig {
  static Map<String, String> get urls {
    if (kIsWeb) {
      return {
        "cataleg": "http://localhost:8081",
        "video": "http://localhost:3000/api",
      };
    }

    if (Platform.isAndroid) {
      return {
        "cataleg": "http://10.0.2.2:8081",
        "video": "http://10.0.2.2:3000/api",
      };
    }

    return {
      "cataleg": "http://localhost:8081",
      "video": "http://localhost:3000/api",
    };
  }
}
