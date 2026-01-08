import { Video } from "../entities/Video";

// Definim el comportament del repositori d'usuaris
export interface IVideoRepository {
  create(video: Video): Promise<Video>;
}