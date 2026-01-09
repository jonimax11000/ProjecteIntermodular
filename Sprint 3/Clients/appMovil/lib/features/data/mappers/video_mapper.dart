import '../../domain/entities/video.dart';

class VideoMapper {
  static Video fromJson(Map<String, dynamic> json) => Video(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration']?.toString() ?? '',
      thumbnail: json['thumbnail'] ?? ''
      /*categoryId: json['categoryId'] ?? 0,
        ageId: json['ageId'] ?? 0,
        seriesId: json['seriesId'] ?? 0,*/
      );
}
