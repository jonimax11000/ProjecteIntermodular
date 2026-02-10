import '../../domain/repositories/videos_repository.dart';
import '../../domain/entities/video.dart';
import '../datasources/videos_api.dart';
import '../mappers/video_mapper.dart';

class VideosRepositoryImpl implements VideosRepository {
  final VideosApi api;

  VideosRepositoryImpl(this.api);

  @override
  Future<List<Video>> getVideos() async {
    final models = await api.fetchVideos();
    return models.map((m) => VideoMapper.fromJson(m)).toList();
  }

  @override
  Future<List<Video>> getVideosBySerie(int serieId) async {
    final models = await api.fetchVideosBySerie(serieId);
    return models.map((m) => VideoMapper.fromJson(m)).toList();
  }

  @override
  Future<List<Video>> getVideosByName(String name) async {
    final models = await api.fetchVideosByName(name);
    return models.map((m) => VideoMapper.fromJson(m)).toList();
  }

  @override
  Future<List<Video>> getVideosByCategoria(int categoriaId) async {
    final models = await api.fetchVideosByCategoria(categoriaId);
    return models.map((m) => VideoMapper.fromJson(m)).toList();
  }

  @override
  Future<List<Video>> getVideosByEdat(int edatId) async {
    final models = await api.fetchVideosByEdat(edatId);
    return models.map((m) => VideoMapper.fromJson(m)).toList();
  }

  @override
  Future<List<Video>> getVideosByNivell(int nivellId) async {
    final models = await api.fetchVideosByNivell(nivellId);
    return models.map((m) => VideoMapper.fromJson(m)).toList();
  }
}
