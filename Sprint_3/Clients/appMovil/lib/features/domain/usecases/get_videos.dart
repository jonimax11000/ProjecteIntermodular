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

  Future<List<Video>> callByName(String name) async {
    return await repository.getVideosByName(name);
  }

  Future<List<Video>> callByCategoria(int categoriaId) async {
    return await repository.getVideosByCategoria(categoriaId);
  }

  Future<List<Video>> callByEdat(int edatId) async {
    return await repository.getVideosByEdat(edatId);
  }

  Future<List<Video>> callByNivell(int nivellId) async {
    return await repository.getVideosByNivell(nivellId);
  }
}
