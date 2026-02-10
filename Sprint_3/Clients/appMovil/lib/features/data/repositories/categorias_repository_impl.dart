import 'package:exercici_disseny_responsiu_stateful/features/data/datasources/categorias_api.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/mappers/categoria_mapper.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/categorias.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/repositories/categorias_repository.dart';

class CategoriasRepositoryImpl implements CategoriasRepository {
  final CategoriasApi api;

  CategoriasRepositoryImpl(this.api);

  @override
  Future<List<Categorias>> getCategorias() async {
    final models = await api.fetchCategorias();
    return models.map((m) => CategoriasMapper.fromJson(m)).toList();
  }
}
