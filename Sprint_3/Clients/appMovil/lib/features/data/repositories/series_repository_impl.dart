import 'package:exercici_disseny_responsiu_stateful/features/data/datasources/series_api.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/mappers/series_mapper.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/series.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/repositories/series_repository.dart';

class SeriesRepositoryImpl implements SeriesRepository {
  final SeriesApi api;

  SeriesRepositoryImpl(this.api);

  @override
  Future<List<Series>> getSeries() async {
    final models = await api.fetchSeries();
    return models.map((m) => SeriesMapper.fromJson(m)).toList();
  }
}
