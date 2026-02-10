// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';

class Series {
  final int id;
  final String nom;
  final int temporada;
  final List<int> videosIds;

  Series({
    required this.id,
    required this.nom,
    required this.temporada,
    required this.videosIds,
  });
}
