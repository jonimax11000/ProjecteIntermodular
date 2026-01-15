import { IVideoRepository } from "../../../domain/repositories/IVideoRepository";
import ffmpeg, { FfprobeData } from 'fluent-ffmpeg';
import { Video } from "../../../domain/entities/Video";
import fs from 'fs';
import path from "path";
import { fileURLToPath } from 'url';


export class CreateVideoUseCase {
  constructor(private videoRepository: IVideoRepository) { }

  // Métodos privados auxiliares
  private esArxiuVideo(nomArxiu: string): boolean {
    const extensionsVideo = ['.mp4', '.avi', '.mov', '.mkv', '.wmv', '.webm'];
    return extensionsVideo.includes(path.extname(nomArxiu).toLowerCase());
  }

  private obtenirMetadadesVideo(nomArxiu: string, carpetaPath: string): Promise<Video> {
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
          thumbnail: `/thumbnails/${nomSenseEspais}.jpg`,
          videoUrl: `/videos/${nomSenseEspais}/index.m3u8`,
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

  private crearInfoVideoBasica(nomArxiu: string, carpetaPath: string): Video {
    const nomVideo = path.parse(nomArxiu).name.toLowerCase();
    const nomSenseEspais = nomVideo.replace(/\s+/g, '');
    const pathComplet = path.join(carpetaPath, nomArxiu);

    return {
      duracio: 0,
      thumbnail: `/thumbnails/${nomSenseEspais}.jpg`,
      videoUrl: `/videos/${nomSenseEspais}/index.m3u8`,
      width: 0,
      height: 0,
      fps: 0,
      bitrate: 0,
      codec: 'unknown',
      fileSize: 0,
      createdAt: fs.existsSync(pathComplet) ? fs.statSync(pathComplet).birthtime : new Date()
    };
  }

  private async obtenerDatosVideo(carpetaPath: string = "./src/app/data/videos"): Promise<Video> {
    try {
      const cwd = process.cwd();
      const carpetaVideos = path.join(cwd, carpetaPath);

      const archivos = fs.readdirSync(carpetaVideos);

      if (archivos.length === 0) {
        throw new Error('No hay archivos en la carpeta');
      }

      const primerArchivo = archivos[0];

      if (this.esArxiuVideo(primerArchivo)) {
        try {
          const video = await this.obtenirMetadadesVideo(primerArchivo, carpetaPath);
          return video;
        } catch (error) {
          console.error(`Error obteniendo metadatos para ${primerArchivo}:`, error);
          return this.crearInfoVideoBasica(primerArchivo, carpetaPath);
        }
      } else {
        throw new Error(`El archivo ${primerArchivo} no es un video válido`);
      }
    } catch (error) {
      console.error('Error leyendo carpeta:', error);
      throw error;
    }
  }

  async execute(): Promise<Video> {
    // Obtener los datos del video desde la carpeta
    const videoData = await this.obtenerDatosVideo();

    // Crear el video usando el repository
    const video = await this.videoRepository.create({
      duracio: videoData.duracio,
      thumbnail: videoData.thumbnail,
      videoUrl: videoData.videoUrl,
      width: videoData.width,
      height: videoData.height,
      fps: videoData.fps,
      bitrate: videoData.bitrate,
      codec: videoData.codec,
      fileSize: videoData.fileSize,
    });

    return video;
  }
}