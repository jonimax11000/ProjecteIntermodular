import { IVideoRepository } from "../../../domain/repositories/IVideoRepository";
import ffmpeg, { FfprobeData } from 'fluent-ffmpeg';
import { Video } from "../../../domain/entities/Video";
import fs from 'fs';
import { VideoProcessor } from "../../../infraestructure/services/videoProcessor";
import { WebSocketManager } from "../../http/websocket/WebSocketManager";
import path from "path";

export class CreateVideoUseCase {
  private videoProcessor: VideoProcessor;

  constructor(
    private videoRepository: IVideoRepository,
    private wsManager?: WebSocketManager
  ) {
    this.videoProcessor = new VideoProcessor();
  }

  async execute(filename: string, nivel: string, jobId?: string, clientId?: string): Promise<Video> {
    try {
      console.log(`Iniciando procesamiento de: ${filename}`);
      await this.videoProcessor.processVideo(filename, nivel);

      const videoData = await this.obtenerDatosVideo(filename,nivel);

      const savedVideo = await this.videoRepository.create(videoData);

      if (this.wsManager && jobId) {
        this.wsManager.notifyProcessingCompleted(
          jobId,
          filename,
          savedVideo
        );
      }

      return savedVideo;

    } catch (error) {
      if (this.wsManager && jobId) {
        this.wsManager.notifyProcessingError(
          jobId,
          filename,
          error instanceof Error ? error.message : 'Error desconocido'
        );
      }
      throw error;
    }
  }


  private esArxiuVideo(nomArxiu: string): boolean {
    const extensionsVideo = ['.mp4', '.avi', '.mov', '.mkv', '.wmv', '.webm'];
    return extensionsVideo.includes(path.extname(nomArxiu).toLowerCase());
  }

  private obtenirMetadadesVideo(nomArxiu: string, carpetaPath: string,nivel: string): Promise<Video> {
    return new Promise((resolve, reject) => {
      const pathComplet = path.join(carpetaPath, nomArxiu);

      ffmpeg.ffprobe(pathComplet, (err: Error | null, metadades: FfprobeData) => {
        if (err) {
          reject(err);
          return;
        }

        const streamVideo = metadades.streams.find((stream) => stream.codec_type === 'video');
        const nomVideo = path.parse(nomArxiu).name.toLowerCase();
        const nomSenseEspais = nomVideo.replace(/\s+/g, '');

        let fps = 0;
        if (streamVideo?.r_frame_rate) {
          const [num, den] = streamVideo.r_frame_rate.split('/').map(Number);
          fps = den !== 0 ? Math.round(num / den) : 0;
        }

        const video: Video = {
          duracio: Math.floor(metadades.format.duration || 0),
          thumbnail: `/thumbnails/${nivel}/${nomSenseEspais}.jpg`,
          videoUrl: `/videos/${nivel}/${nomSenseEspais}/index.m3u8`,
          width: streamVideo?.width || 0,
          height: streamVideo?.height || 0,
          fps: fps,
          bitrate: parseInt(metadades.format.bit_rate || '0'),
          codec: streamVideo?.codec_name || 'unknown',
          fileSize: metadades.format.size || 0,
          createdAt: fs.statSync(pathComplet).birthtime
        };

        resolve(video);
      });
    });
  }

  private crearInfoVideoBasica(nomArxiu: string, carpetaPath: string,nivel: string): Video {
    const nomVideo = path.parse(nomArxiu).name.toLowerCase();
    const nomSenseEspais = nomVideo.replace(/\s+/g, '');
    const pathComplet = path.join(carpetaPath, nomArxiu);

    return {
      duracio: 0,
      thumbnail: `/thumbnails/${nivel}/${nomSenseEspais}.jpg`,
      videoUrl: `/videos/${nivel}/${nomSenseEspais}/index.m3u8`,
      width: 0,
      height: 0,
      fps: 0,
      bitrate: 0,
      codec: 'unknown',
      fileSize: 0,
      createdAt: fs.existsSync(pathComplet) ? fs.statSync(pathComplet).birthtime : new Date()
    };
  }

  private async obtenerDatosVideo(filename: string,nivel: string, carpetaPath: string = "./src/app/data/videos"): Promise<Video> {
    const cwd = process.cwd();
    const pathAbsolutCarpeta = path.join(cwd, carpetaPath);

    if (!this.esArxiuVideo(filename)) {
      throw new Error(`El archivo ${filename} no es un video válido`);
    }

    try {
      return await this.obtenirMetadadesVideo(filename, pathAbsolutCarpeta,nivel);
    } catch (error) {
      console.error(`Error obteniendo metadatos para ${filename}:`, error);
      return this.crearInfoVideoBasica(filename, pathAbsolutCarpeta,nivel);
    }
  }
}