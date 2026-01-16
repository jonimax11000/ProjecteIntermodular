import { IVideoRepository } from "../../../domain/repositories/IVideoRepository";
import { Video } from "../../../domain/entities/Video";
import { VideoMapper } from "../../mappers/VideoMapper";
import { VideoRecord } from "./models/VideoRecord";
import { videos } from "../../../data/videos";

export class VideoRepositoryIntern implements IVideoRepository {

  async create(video: Omit<Video, "createdAt">): Promise<Video> {
    const record: VideoRecord = { createdAt: new Date().toISOString(), ...video };
    // Ensure we add it to the in-memory store so it can be deleted later
    videos.push(VideoMapper.toDomain(record));
    return VideoMapper.toDomain(record);
  }

  async delete(video: string, thumbnail: string): Promise<string> {

    return "Video eliminado correctamente";
  }

}
