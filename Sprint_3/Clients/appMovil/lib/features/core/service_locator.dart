import 'package:exercici_disseny_responsiu_stateful/config/api_config.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/datasources/videos_api.dart';
import 'package:exercici_disseny_responsiu_stateful/features/data/repositories/videos_repository_impl.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/repositories/videos_repository.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_videos.dart';

class ServiceLocator {
  String remoteCatalegUrl =
      ApiConfig.urls["cataleg"] ?? "http://localhost:8081";
  String remoteVideoUrl =
      ApiConfig.urls["video"] ?? "http://localhost:3000/api";

  static ServiceLocator? _instancia;

  late VideosRepository _videosRepository;

  late VideosApi _api;

  late final GetVideos getVideos;

  factory ServiceLocator() {
    _instancia ??= ServiceLocator._();
    return _instancia!;
  }

  ServiceLocator._() {
    _api = VideosApi(remoteCatalegUrl);
    _videosRepository = VideosRepositoryImpl(_api);
    getVideos = GetVideos(_videosRepository);
  }

  String getCatalegUrl() => remoteCatalegUrl;
  String getVideoUrl() => remoteVideoUrl;
}
