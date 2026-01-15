import { IVideoRepository } from "../../../domain/repositories/IVideoRepository";
import { Video } from "../../../domain/entities/Video";
import { VideoMapper } from "../../mappers/VideoMapper";
import { VideoRecord } from "./models/VideoRecord";

export class VideoRepositoryIntern implements IVideoRepository {

  async create(video: Omit<Video, "createdAt">): Promise<Video> {
    const record: VideoRecord = { createdAt: new Date().toISOString(), ...video };

    return VideoMapper.toDomain(record);
  }

  async delete(video: String, thumbnail: String): Promise<String> {
    return "Video deleted successfully";
  }

}
