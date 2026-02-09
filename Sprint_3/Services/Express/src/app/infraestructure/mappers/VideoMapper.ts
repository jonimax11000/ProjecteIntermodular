import { Video } from "../../domain/entities/Video";
import { VideoRecord } from "../datasorces/intern/models/VideoRecord";

export class VideoMapper {
  static toDomain(record: VideoRecord): Video {
    return {
      ...record,
      createdAt: new Date(record.createdAt),
    };
  }

  static toRecord(video: Omit<Video, "createdAt"> & { createdAt: Date }): VideoRecord {
    return {
      ...video,
      createdAt: video.createdAt.toISOString(),

    };
  }
}