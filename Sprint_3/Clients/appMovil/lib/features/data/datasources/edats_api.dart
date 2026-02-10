import 'dart:convert';
import 'package:exercici_disseny_responsiu_stateful/features/core/api_client.dart';

class EdatsApi {
  String baseUrl;

  EdatsApi(this.baseUrl);

  Future<List<Map<String, dynamic>>> fetchEdats() async {
    final uri = Uri.parse(baseUrl);
    try {
      final res = await ApiClient.client.get(uri);
      if (res.statusCode == 200) {
        final decoded = json.decode(utf8.decode(res.bodyBytes));
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load edats: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching edats: $e');
    }
  }
}
