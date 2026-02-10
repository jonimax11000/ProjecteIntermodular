import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/categorias.dart';

class CategoriasMapper {
    static Categorias fromJson(Map<String, dynamic> json) => Categorias(
      id: int.parse(json['id'].toString()),
      categoria: json['categoria'] ?? '',
      videosIds: (json['videos'] is List)
      ? (json['videos'] as List).map((v) => v is int ? v : int.tryParse(v.toString()) ?? 0).toList()
      : [],
    );
}
