import '../../domain/entities/video.dart';

class VideoMapper {
  static Video fromJson(Map<String, dynamic> json) => Video(
        id: int.parse(json['id'].toString()),
        titol: json['titol'] ?? '',
        videoURL: json['videoURL'] ?? '',
        thumbnailURL: json['thumbnailURL'] ?? '',
        duracio: json['duracio']?.toString() ?? '',
        /*categoryId: json['categoryId'] ?? 0,
        ageId: json['ageId'] ?? 0,
        seriesId: json['seriesId'] ?? 0,*/
      );
}
