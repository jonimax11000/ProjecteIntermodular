import 'package:exercici_disseny_responsiu_stateful/features/data/datasources/edats_api.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/edat.dart';

class GetEdats {
  final EdatsApi api;
  GetEdats(this.api);

  Future<List<Edat>> call() async {
    final list = await api.fetchEdats();
    return list.map((e) => Edat.fromJson(e)).toList();
  }
}
