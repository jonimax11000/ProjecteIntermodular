import ffmpeg, { FfprobeData } from 'fluent-ffmpeg';
import { Video } from '../domain/entities/Video';
import fs from 'fs';
import path from 'path';

// Inicialització de l'array d'videos
export let videos: Array<Video> = [];

// Funció per carregar videos des d'una carpeta amb metadades reals
export const carregarVideosDesDeCarpeta = async (carpetaPath: string,nivel: string): Promise<Video[]> => {
  const videosTrobats: Video[] = [];

  try {
    const arxius = fs.readdirSync(carpetaPath);

    for (const arxiu of arxius) {
      if (esArxiuVideo(arxiu)) {
        try {
          const video = await obtenirMetadadesVideo(arxiu, carpetaPath,nivel);
          videosTrobats.push(video);
        } catch (error) {
          console.error(`Error llegint metadades per ${arxiu}:`, error);
          videosTrobats.push(crearInfoVideoBasica(arxiu, carpetaPath));
        }
      }
    }

    videos = videosTrobats;
    console.log(`📹 Carregats ${videos.length} videos des de la carpeta.`);
    return videos;

  } catch (error) {
    console.error('Error llegint carpeta:', error);
    return [];
  }
};

// Funcions auxiliars
function esArxiuVideo(nomArxiu: string): boolean {
  const extensionsVideo = ['.mp4', '.avi', '.mov', '.mkv', '.wmv', '.webm'];
  return extensionsVideo.includes(path.extname(nomArxiu).toLowerCase());
}

function obtenirMetadadesVideo(nomArxiu: string, carpetaPath: string,nivel: string): Promise<Video> {
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

function crearInfoVideoBasica(nomArxiu: string, carpetaPath: string): Video {
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