import 'dart:convert';

import 'package:exercici_disseny_responsiu_stateful/features/core/api_client.dart';

class CategoriasApi {
  String baseUrl;

  CategoriasApi(this.baseUrl);

  Future<List<Map<String, dynamic>>> fetchCategorias() async {
    final uri = Uri.parse(baseUrl);
    try {
      final res = await ApiClient.client.get(uri);
      if (res.statusCode == 200) {
        final decoded = json.decode(utf8.decode(res.bodyBytes));
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
