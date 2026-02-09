import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/categorias.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/repositories/categorias_repository.dart';

class GetCategorias {
  final CategoriasRepository repository;

  GetCategorias(this.repository);

  Future<List<Categorias>> call() async {
    return await repository.getCategorias();
  }
}
