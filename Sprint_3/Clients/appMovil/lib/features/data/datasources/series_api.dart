import 'dart:convert';
import 'package:exercici_disseny_responsiu_stateful/features/core/api_client.dart';

class SeriesApi {
  String baseUrl;
  String baseUrlByName;

  SeriesApi(this.baseUrl, this.baseUrlByName);

  Future<List<Map<String, dynamic>>> fetchSeries() async {
    final uri = Uri.parse(baseUrl);
    try {
      final res = await ApiClient.client.get(uri);
      if (res.statusCode == 200) {
        String body = utf8.decode(res.bodyBytes);
        final decoded = json.decode(res.body);
        if (decoded is List) {
          return decoded.map<Map<String, dynamic>>((e) {
            return {
              'id': e['id'] ?? 0,
              'nom': e['nom'] ?? '',
              'temporada': e['temporada'] ?? 0,
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

  Future<List<Map<String, dynamic>>> fetchSeriesByName(String name) async {
    final uri =
        Uri.parse(baseUrlByName.replaceAll(':name', name.toLowerCase()));
    try {
      final res = await ApiClient.client.get(uri);
      if (res.statusCode == 200) {
        String body = utf8.decode(res.bodyBytes);
        final decoded = json.decode(res.body);
        if (decoded is List) {
          return decoded.map<Map<String, dynamic>>((e) {
            return {
              'id': e['id'] ?? 0,
              'nom': e['nom'] ?? '',
              'temporada': e['temporada'] ?? 0,
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
