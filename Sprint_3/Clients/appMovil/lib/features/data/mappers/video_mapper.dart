import '../../domain/entities/video.dart';

class VideoMapper {
  static Video fromJson(Map<String, dynamic> json) => Video(
        id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        titol: json['titol']?.toString() ?? '',
        videoURL: json['videoURL']?.toString() ?? '',
        thumbnailURL: json['thumbnailURL']?.toString() ?? '',
        descripcio: json['descripcio']?.toString() ?? '',
        duracio: json['duracio']?.toString() ?? '',
        serie: int.tryParse(json['serie']?.toString() ?? '0') ?? 0,
        edat: int.tryParse(json['edat']?.toString() ?? '0') ?? 0,
        nivell: int.tryParse(json['nivell']?.toString() ?? '0') ?? 0,
        categories: json['categories'] != null
            ? List<int>.from(
                json['categories'].map((e) => int.tryParse(e.toString()) ?? 0))
            : [],
      );
}
