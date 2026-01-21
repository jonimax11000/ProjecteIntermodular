import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/series.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/repositories/series_repository.dart';

class GetSeries {
  final SeriesRepository repository;

  GetSeries(this.repository);

  Future<List<Series>> call() async {
    return await repository.getSeries();
  }
}
