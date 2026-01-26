import '../entities/video.dart';
import '../repositories/videos_repository.dart';

class GetVideos {
  final VideosRepository repository;

  GetVideos(this.repository);

  Future<List<Video>> call() async {
    return await repository.getVideos();
  }

  Future<List<Video>> callBySerie(int serieId) async {
    return await repository.getVideosBySerie(serieId);
  }
}
