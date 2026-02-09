import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/series.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';

class SeriesMapper {
  static Series fromJson(Map<String, dynamic> json) => Series(
        id: int.parse(json['id'].toString()),
        nom: json['nom'] ?? '',
        temporada: json['temporada'] ?? '',
        videosIds: List<int>.from(json['videos'] ?? []),
      );
}
