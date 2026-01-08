import { IVideoRepository } from "../../../domain/repositories/IVideoRepository";
import { Video } from "../../../domain/entities/Video";

export class CreateVideoUseCase {
  constructor(private videoRepository: IVideoRepository) {

    /*async execute(
      titol: string,
      video: Video
    ): //aquí irá el código para procesar el video, partirlo en partes y sacar los datos
      Promise<Video> {
      const video = await this.videoRepository.create({
        duracio,
        thumbnail,
        videoUrl,
        width,
        height,
        fps,
        bitrate,
        codec,
        fileSize,
        createdAt: new Date().toISOString(),
        id
      });
  
      return video;*/
  }
}
