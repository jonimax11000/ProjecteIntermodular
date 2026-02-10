import 'package:exercici_disseny_responsiu_stateful/features/data/datasources/nivells_api.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/nivell.dart';

class GetNivells {
  final NivellsApi api;
  GetNivells(this.api);

  Future<List<Nivell>> call() async {
    final list = await api.fetchNivells();
    return list.map((e) => Nivell.fromJson(e)).toList();
  }
}
