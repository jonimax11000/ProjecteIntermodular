import 'dart:convert';

import 'package:http/http.dart' as http;

class CategoriasApi {
  String baseUrl;

  CategoriasApi(this.baseUrl);
  

  Future<List<Map<String, dynamic>>> fetchCategorias() async {
    final uri = Uri.parse(baseUrl);
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        String body = utf8.decode(res.bodyBytes);
        final decoded = json.decode(res.body);
        if (decoded is List) {
          return decoded.map<Map<String, dynamic>>((e) {
            return {
              'id': e['id'] ?? 0,
              'categoria': e['categoria'] ?? '',
              'videos': List<int>.from(e['videos'] ?? []),
            };
          }).toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load videos: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching videos: $e');
    }
  }
}
