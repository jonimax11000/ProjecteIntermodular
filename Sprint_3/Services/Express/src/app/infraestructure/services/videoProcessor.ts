import ffmpeg from 'fluent-ffmpeg';
import fs from 'fs';
import path from 'path';

export class VideoProcessor {
  private readonly videosSourcePath = './src/app/data/videos';
  private readonly videosPublicPath = './src/app/public/videos';
  private readonly thumbnailsPublicPath = './src/app/public/thumbnails';

  constructor() {
    this.ensureDirectories();
  }


  private ensureDirectories(): void {
    if (!fs.existsSync(this.videosPublicPath)) {
      fs.mkdirSync(this.videosPublicPath, { recursive: true });
    }
    if (!fs.existsSync(this.thumbnailsPublicPath)) {
      fs.mkdirSync(this.thumbnailsPublicPath, { recursive: true });
    }
  }

  public async processVideo(filename: string, nivel: string): Promise<void> {
    console.log(`Nivel Process Video: ${nivel}`);
    const videoName = path.parse(filename).name.toLowerCase().replace(/\s+/g, '');
    const inputPath = path.join(this.videosSourcePath, filename);

    // Procesar en paralelo: thumbnail y HLS
    await Promise.all([
      this.generateThumbnail(inputPath, videoName, nivel),
      this.generateHLS(inputPath, videoName, nivel)
    ]);
  }

  private generateThumbnail(inputPath: string, videoName: string, nivel: string): Promise<void> {
    return new Promise((resolve, reject) => {
      console.log(`Nivel Generate Thumbnail: ${nivel}`);
      const outputPath = path.join(this.thumbnailsPublicPath, nivel, `${videoName}.jpg`);

      ffmpeg(inputPath)
        .screenshots({
          timestamps: ['00:00:01'],
          filename: path.basename(outputPath),
          folder: path.dirname(outputPath),
          size: '320x180'
        })
        .on('end', () => {
          console.log(`   📸 Thumbnail generado: ${videoName}.jpg`);
          resolve();
        })
        .on('error', (err) => {
          console.error(`   ❌ Error en thumbnail ${videoName}:`, err);
          reject(err);
        });
    });
  }

  private generateHLS(inputPath: string, videoName: string, nivel: string): Promise<void> {
    return new Promise((resolve, reject) => {
      const outputDir = path.join(this.videosPublicPath, nivel, videoName);

      // Crear directorio para el video HLS
      if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
      }

      ffmpeg(inputPath)
        .outputOptions([
          '-profile:v baseline',
          '-level 3.0',
          '-start_number 0',
          '-hls_time 10',
          '-hls_list_size 0',
          '-f hls'
        ])
        .output(path.join(outputDir, 'index.m3u8'))
        .on('start', (commandLine) => {
          console.log(`   🎥 Iniciando HLS para: ${videoName}`);
        })
        .on('progress', (progress) => {
          if (progress.percent) {
            console.log(`   📊 Progreso ${videoName}: ${Math.round(progress.percent)}%`);
          }
        })
        .on('end', () => {
          console.log(`   ✅ HLS completado: ${videoName}`);
          resolve();
        })
        .on('error', (err) => {
          console.error(`   ❌ Error en HLS ${videoName}:`, err);
          reject(err);
        })
        .run();
    });
  }

  private isVideoFile(filename: string): boolean {
    const extensionsVideo = ['.mp4', '.avi', '.mov', '.mkv', '.wmv', '.webm'];
    return extensionsVideo.includes(path.extname(filename).toLowerCase());
  }
}