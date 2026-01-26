import 'package:exercici_disseny_responsiu_stateful/config/api_config.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/datasources/categorias_api.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/datasources/series_api.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/datasources/videos_api.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/repositories/categorias_repository_impl.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/repositories/series_repository_impl.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/repositories/videos_repository_impl.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/repositories/categorias_repository.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/repositories/series_repository.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/repositories/videos_repository.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_categorias.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_series.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_videos.dart';

class ServiceLocator {
  String remoteCatalegUrl =
      ApiConfig.urls["cataleg"] ?? "http://localhost:8081/api/cataleg";
  String remoteCatalegBySeriesUrl = ApiConfig.urls["catalegBySeries"] ??
      "http://localhost:8081/api/catalegBySeries/:id";
  String remoteVideoUrl =
      ApiConfig.urls["video"] ?? "http://localhost:3000/api";
  String remoteSeriesUrl =
      ApiConfig.urls["series"] ?? "http://localhost:8081/api/series";
  String remoteCategoriasUrl =
      ApiConfig.urls["categorias"] ?? "http://localhost:8081/api/categories";

  static ServiceLocator? _instancia;

  late VideosRepository _videosRepository;
  late SeriesRepository _seriesRepository;
  late CategoriasRepository _categoriasRepository;

  late VideosApi _api;
  late SeriesApi _seriesApi;
  late CategoriasApi _categoriasApi;

  late final GetVideos getVideos;
  late final GetSeries getSeries;
  late final GetCategorias getCategorias;

  factory ServiceLocator() {
    _instancia ??= ServiceLocator._();
    return _instancia!;
  }

  ServiceLocator._() {
    _api = VideosApi(
      remoteCatalegUrl,
      remoteCatalegBySeriesUrl,
    );
    _seriesApi = SeriesApi(remoteSeriesUrl);
    _categoriasApi = CategoriasApi(remoteCategoriasUrl);

    _videosRepository = VideosRepositoryImpl(_api);
    _seriesRepository = SeriesRepositoryImpl(_seriesApi);
    _categoriasRepository = CategoriasRepositoryImpl(_categoriasApi);

    getVideos = GetVideos(_videosRepository);
    getSeries = GetSeries(_seriesRepository);
    getCategorias = GetCategorias(_categoriasRepository);
  }

  String getCatalegUrl() => remoteCatalegUrl;
  String getVideoUrl() => remoteVideoUrl;
  String getSeriesUrl() => remoteSeriesUrl;
  String getCategoriasUrl() => remoteCategoriasUrl;
}
