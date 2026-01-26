import 'dart:convert';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/categorias.dart';
import 'package:http/http.dart' as http;

class VideosApi {
  String baseUrl;
  String baseUrlBySeries;

  VideosApi(this.baseUrl, this.baseUrlBySeries);

  Future<List<Map<String, dynamic>>> fetchVideos() async {
    final uri = Uri.parse(baseUrl);
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        String body = utf8.decode(res.bodyBytes);
        final decoded = json.decode(res.body);
        if (decoded is List) {
          return decoded.map<Map<String, dynamic>>((e) {
            return {
              'id': e['id'] as int ?? 0,
              'titol': e['titol'] ?? '',
              'videoURL': e['videoURL'] ?? '',
              'thumbnailURL': e['thumbnailURL'] ?? '',
              'descripcio': e['descripcio']?.toString() ?? '',
              'duracio': e['duracio']?.toString() ?? '',
              'serie': e['serie'] ?? 0,
              'edat': e['edat'] ?? 0,
              'nivell': e['nivell'] ?? 0,
              'categories': List<int>.from(e['categories']) ?? [],
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

  Future<List<Map<String, dynamic>>> fetchVideosBySerie(int serieId) async {
    final uri =
        Uri.parse(baseUrlBySeries.replaceAll(':id', serieId.toString()));
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        String body = utf8.decode(res.bodyBytes);
        final decoded = json.decode(res.body);
        if (decoded is List) {
          return decoded.map<Map<String, dynamic>>((e) {
            return {
              'id': e['id'] as int ?? 0,
              'titol': e['titol'] ?? '',
              'videoURL': e['videoURL'] ?? '',
              'thumbnailURL': e['thumbnailURL'] ?? '',
              'descripcio': e['descripcio']?.toString() ?? '',
              'duracio': e['duracio']?.toString() ?? '',
              'serie': e['serie'] ?? 0,
              'edat': e['edat'] ?? 0,
              'nivell': e['nivell'] ?? 0,
              'categories': List<int>.from(e['categories']) ?? [],
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
