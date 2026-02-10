import 'dart:convert';
import 'package:exercici_disseny_responsiu_stateful/features/core/api_client.dart';

class VideosApi {
  String baseUrl;
  String baseUrlBySeries;
  String baseUrlByName;
  String baseUrlByCategoria;
  String baseUrlByEdat;
  String baseUrlByNivell;

  VideosApi(
    this.baseUrl,
    this.baseUrlBySeries,
    this.baseUrlByName,
    this.baseUrlByCategoria,
    this.baseUrlByEdat,
    this.baseUrlByNivell,
  );

  Future<List<Map<String, dynamic>>> fetchVideos() async {
    final uri = Uri.parse(baseUrl);
    return _fetchVideosFromUri(uri);
  }

  Future<List<Map<String, dynamic>>> fetchVideosBySerie(int serieId) async {
    final uri =
        Uri.parse(baseUrlBySeries.replaceAll(':id', serieId.toString()));
    return _fetchVideosFromUri(uri);
  }

  Future<List<Map<String, dynamic>>> fetchVideosByName(String name) async {
    final uri =
        Uri.parse(baseUrlByName.replaceAll(':name', name.toLowerCase()));
    return _fetchVideosFromUri(uri);
  }

  Future<List<Map<String, dynamic>>> fetchVideosByCategoria(
      int categoriaId) async {
    final uri =
        Uri.parse(baseUrlByCategoria.replaceAll(':id', categoriaId.toString()));
    return _fetchVideosFromUri(uri);
  }

  Future<List<Map<String, dynamic>>> fetchVideosByEdat(int edatId) async {
    final uri = Uri.parse(baseUrlByEdat.replaceAll(':id', edatId.toString()));
    return _fetchVideosFromUri(uri);
  }

  Future<List<Map<String, dynamic>>> fetchVideosByNivell(int nivellId) async {
    final uri =
        Uri.parse(baseUrlByNivell.replaceAll(':id', nivellId.toString()));
    return _fetchVideosFromUri(uri);
  }

  Future<List<Map<String, dynamic>>> _fetchVideosFromUri(Uri uri) async {
    try {
      final res = await ApiClient.client.get(uri);
      if (res.statusCode == 200) {
        String body = utf8.decode(res.bodyBytes);
        final decoded = json.decode(body);
        if (decoded is List) {
          return decoded.map<Map<String, dynamic>>((e) {
            return {
              'id': e['id'] as int,
              'titol': e['titol'] ?? '',
              'videoURL': e['videoURL'] ?? '',
              'thumbnailURL': e['thumbnailURL'] ?? '',
              'descripcio': e['descripcio']?.toString() ?? '',
              'duracio': e['duracio']?.toString() ?? '',
              'serie': e['serie'] ?? 0,
              'edat': e['edat'] ?? 0,
              'nivell': e['nivell'] ?? 0,
              'categories': List<int>.from(e['categories'] ?? []),
            };
          }).toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load videos: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching videos from $uri: $e');
    }
  }
}
