import { Video } from "../entities/Video";

// Definim el comportament del repositori d'usuaris
export interface IVideoRepository {
  create(video: Omit<Video, "createdAt">): Promise<Video>;
  delete(video: String, thumbnail: String): Promise<String>;
}