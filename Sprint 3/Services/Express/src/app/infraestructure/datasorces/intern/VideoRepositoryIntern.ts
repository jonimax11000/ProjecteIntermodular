import { IVideoRepository } from "../../../domain/repositories/IVideoRepository";
import { Video } from "../../../domain/entities/Video";
import { VideoMapper } from "../../mappers/VideoMapper";
import { VideoRecord } from "./models/VideoRecord";
import { videos } from "../../../data/videos";

export class VideoRepositoryIntern implements IVideoRepository {
  private vids: VideoRecord[] = videos;

  async create(video: Omit<Video>): Promise<Video> {
    const record: VideoRecord = { video };

    this.vids.push(record);

    return VideoMapper.toDomain(record);
  }

}
