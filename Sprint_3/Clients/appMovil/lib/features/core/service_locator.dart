import 'package:exercici_disseny_responsiu_stateful/config/api_config.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/datasources/series_api.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/datasources/videos_api.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/repositories/series_repository_impl.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/repositories/videos_repository_impl.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/series.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/repositories/series_repository.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/repositories/videos_repository.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_series.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_videos.dart';

class ServiceLocator {
  String remoteCatalegUrl =
      ApiConfig.urls["cataleg"] ?? "http://localhost:8081/api/cataleg";
  String remoteVideoUrl =
      ApiConfig.urls["video"] ?? "http://localhost:3000/api";
  String remoteSeriesUrl =
      ApiConfig.urls["series"] ?? "http://localhost:8081/api/series";
  static ServiceLocator? _instancia;

  late VideosRepository _videosRepository;
  late SeriesRepository _seriesRepository;

  late VideosApi _api;
  late SeriesApi _seriesApi;

  late final GetVideos getVideos;
  late final GetSeries getSeries;

  factory ServiceLocator() {
    _instancia ??= ServiceLocator._();
    return _instancia!;
  }

  ServiceLocator._() {
    _api = VideosApi(remoteCatalegUrl);
    _seriesApi = SeriesApi(remoteSeriesUrl);

    _videosRepository = VideosRepositoryImpl(_api);
    _seriesRepository = SeriesRepositoryImpl(_seriesApi);

    getVideos = GetVideos(_videosRepository);
    getSeries = GetSeries(_seriesRepository);
  }

  String getCatalegUrl() => remoteCatalegUrl;
  String getVideoUrl() => remoteVideoUrl;
}
