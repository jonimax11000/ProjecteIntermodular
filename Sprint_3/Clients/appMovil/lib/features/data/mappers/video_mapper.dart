import '../../domain/entities/video.dart';

class VideoMapper {
  static Video fromJson(Map<String, dynamic> json) => Video(
        id: int.parse(json['id'].toString()),
        titol: json['titol'] ?? '',
        videoURL: json['videoURL'] ?? '',
        thumbnailURL: json['thumbnailURL'] ?? '',
        descripcio: json['descripcio']?.toString() ?? '',
        duracio: json['duracio']?.toString() ?? '',
        serie: json['serie'] ?? 0,
        edat: json['edat'] ?? 0,
        nivell: json['nivell'] ?? 0,
        categories: List<int>.from(json['categories'] ?? []),
      );
}
