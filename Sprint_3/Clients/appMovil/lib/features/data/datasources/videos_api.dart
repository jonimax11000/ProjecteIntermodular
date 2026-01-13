import 'dart:convert';
import 'package:http/http.dart' as http;

class VideosApi {
  final String baseUrl;
  VideosApi({this.baseUrl = 'http://localhost:8081'});

  Future<List<Map<String, dynamic>>> fetchVideos() async {
    final uri = Uri.parse('$baseUrl/api/cataleg');
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded is List) {
          return decoded.map<Map<String, dynamic>>((e) {
            return {
              'id': e['id'] as int ?? 0,
              'titol': e['titol'] ?? '',
              'videoURL': e['videoURL'] ?? '',
              'thumbnailURL': e['thumbnailURL'] ?? '',
              'duracio': e['duracio']?.toString() ?? '',
              /*'categoryId': e['categoryId'] ?? 0,
              'ageId': e['ageId'] ?? 0,
              'seriesId': e['seriesId'] ?? 0,*/
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
