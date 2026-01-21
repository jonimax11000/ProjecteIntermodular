import 'dart:convert';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';
import 'package:http/http.dart' as http;

class SeriesApi {
  String baseUrl;

  SeriesApi(this.baseUrl);

  Future<List<Map<String, dynamic>>> fetchSeries() async {
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
