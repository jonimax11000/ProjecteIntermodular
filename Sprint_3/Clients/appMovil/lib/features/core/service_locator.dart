import 'package:exercici_disseny_responsiu_stateful/config/api_config.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/datasources/categorias_api.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/datasources/series_api.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/datasources/videos_api.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/datasources/edats_api.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/datasources/nivells_api.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/repositories/categorias_repository_impl.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/repositories/series_repository_impl.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/repositories/videos_repository_impl.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/repositories/categorias_repository.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/repositories/series_repository.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/repositories/videos_repository.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_categorias.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_series.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_videos.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_edats.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_nivells.dart';

class ServiceLocator {
  String remoteCatalegUrl =
      ApiConfig.urls["cataleg"] ?? "https://localhost:8081/api/cataleg";
  String remoteCatalegBySeriesUrl = ApiConfig.urls["catalegBySeries"] ??
      "https://localhost:8081/api/catalegBySeries/:id";
  String remoteCatalegByNameUrl = ApiConfig.urls["catalegByName"] ??
      "https://localhost:8081/api/catalegByName/:name";
  String remoteCatalegByCategoriaUrl = ApiConfig.urls["catalegByCategoria"] ??
      "https://localhost:8081/api/catalegByCategoria/:id";
  String remoteCatalegByEdatUrl = ApiConfig.urls["catalegByEdat"] ??
      "https://localhost:8081/api/catalegByEdat/:id";
  String remoteCatalegByNivellUrl = ApiConfig.urls["catalegByNivell"] ??
      "https://localhost:8081/api/catalegByNivell/:id";
  String remoteVideoUrl =
      ApiConfig.urls["video"] ?? "https://localhost:3000/api";
  String remoteSeriesUrl =
      ApiConfig.urls["series"] ?? "https://localhost:8081/api/series";
  String remoteSeriesByNameUrl = ApiConfig.urls["series"] ??
      "https://localhost:8081/api/seriesByName/:name";
  String remoteCategoriasUrl =
      ApiConfig.urls["categorias"] ?? "https://localhost:8081/api/categories";
  String remoteEdatsUrl =
      ApiConfig.urls["edats"] ?? "https://localhost:8081/api/edats";
  String remoteNivellsUrl =
      ApiConfig.urls["nivells"] ?? "https://localhost:8081/api/nivells";

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
  late final GetEdats getEdats;
  late final GetNivells getNivells;

  factory ServiceLocator() {
    _instancia ??= ServiceLocator._();
    return _instancia!;
  }

  ServiceLocator._() {
    _api = VideosApi(
      remoteCatalegUrl,
      remoteCatalegBySeriesUrl,
      remoteCatalegByNameUrl,
      remoteCatalegByCategoriaUrl,
      remoteCatalegByEdatUrl,
      remoteCatalegByNivellUrl,
    );
    _seriesApi = SeriesApi(remoteSeriesUrl, remoteSeriesByNameUrl);
    _categoriasApi = CategoriasApi(remoteCategoriasUrl);

    _videosRepository = VideosRepositoryImpl(_api);
    _seriesRepository = SeriesRepositoryImpl(_seriesApi);
    _categoriasRepository = CategoriasRepositoryImpl(_categoriasApi);

    getVideos = GetVideos(_videosRepository);
    getSeries = GetSeries(_seriesRepository);
    getCategorias = GetCategorias(_categoriasRepository);
    getEdats = GetEdats(EdatsApi(remoteEdatsUrl));
    getNivells = GetNivells(NivellsApi(remoteNivellsUrl));
  }

  String getCatalegUrl() => remoteCatalegUrl;
  String getVideoUrl() => remoteVideoUrl;
  String getSeriesUrl() => remoteSeriesUrl;
  String getCategoriasUrl() => remoteCategoriasUrl;
  String getVideosByNameUrl() => remoteCatalegByNameUrl;
  String getSeriesByNameUrl() => remoteSeriesByNameUrl;
}
