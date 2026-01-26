import '../entities/video.dart';

abstract class VideosRepository {
  Future<List<Video>> getVideos();
  Future<List<Video>> getVideosBySerie(int serieId);
}
