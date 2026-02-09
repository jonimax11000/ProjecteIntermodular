import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/series.dart';

abstract class SeriesRepository {
  Future<List<Series>> getSeries();
  Future<List<Series>> getSeriesByName(String name);
}
