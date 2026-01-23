import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/categorias.dart';

class Video {
  final int id;
  final String titol;
  final String videoURL;
  final String thumbnailURL;
  final String duracio;
  final String? descripcio;
  final int? serie;
  final int? edat;
  final int? nivell;
  final List<int>? categories;

  Video(
      {required this.id,
      required this.titol,
      required this.videoURL,
      required this.thumbnailURL,
      required this.duracio,
      this.descripcio,
      this.serie,
      this.edat,
      this.nivell,
      this.categories});
}
