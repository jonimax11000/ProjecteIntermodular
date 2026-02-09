import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/categorias.dart';

abstract class CategoriasRepository {
  Future<List<Categorias>> getCategorias();
}
