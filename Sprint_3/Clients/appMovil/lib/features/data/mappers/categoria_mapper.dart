import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/categorias.dart';

class CategoriasMapper {
  static Categorias fromJson(Map<String, dynamic> json) => Categorias(
        id: int.parse(json['id'].toString()),
        categoria: json['categoria'] ?? '',
        videosIds: List<int>.from(json['videos'] ?? []),
      );
}
