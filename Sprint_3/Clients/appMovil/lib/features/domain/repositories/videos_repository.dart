import '../entities/video.dart';

abstract class VideosRepository {
  Future<List<Video>> getVideos();
  Future<List<Video>> getVideosBySerie(int serieId);
  Future<List<Video>> getVideosByName(String name);
  Future<List<Video>> getVideosByCategoria(int categoriaId);
  Future<List<Video>> getVideosByEdat(int edatId);
  Future<List<Video>> getVideosByNivell(int nivellId);
}
