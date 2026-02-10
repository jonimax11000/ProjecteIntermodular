import path from "path";
import fs from "fs";
import { IVideoRepository } from "../../../domain/repositories/IVideoRepository";

export class DeleteVideoUseCase {
  private readonly videosPublicPath = "./src/app/public/";
  private readonly thumbnailsPublicPath = "./src/app/public/";

  constructor(private videoRepository: IVideoRepository) {}

  async execute(video: string, thumbnail: string): Promise<string> {
    const cwd = process.cwd();

    // Extraer la ruta relativa si se pasa una URL completa
    const getRelativePath = (input: string) => {
      if (input.startsWith("http")) {
        try {
          const url = new URL(input);
          let p = url.pathname;
          if (p.startsWith("/api")) p = p.slice(4);
          return p;
        } catch (e) {
          return input;
        }
      }
      return input;
    };

    const relVideo = getRelativePath(video);
    const relThumb = getRelativePath(thumbnail);

    const cleanVideoPath = relVideo.startsWith("/")
      ? relVideo.slice(1)
      : relVideo;
    const cleanThumbnailPath = relThumb.startsWith("/")
      ? relThumb.slice(1)
      : relThumb;

    const fullVideoPath = path.join(cwd, this.videosPublicPath, cleanVideoPath);
    const fullThumbnailPath = path.join(
      cwd,
      this.thumbnailsPublicPath,
      cleanThumbnailPath,
    );

    const videoDir = path.dirname(fullVideoPath);

    console.log(`Intentando borrar videoDir: ${videoDir}`);
    console.log(`Intentando borrar thumbnail: ${fullThumbnailPath}`);

    try {
      let deleted = false;

      if (fs.existsSync(videoDir)) {
        fs.rmSync(videoDir, { recursive: true, force: true });
        console.log(`Carpeta eliminada: ${videoDir}`);
        deleted = true;
      }

      if (fs.existsSync(fullThumbnailPath)) {
        fs.unlinkSync(fullThumbnailPath);
        console.log(`Thumbnail eliminado: ${fullThumbnailPath}`);
        deleted = true;
      }

      if (!deleted) {
        console.warn(
          "No se encontró ni el video ni el thumbnail físicamente, pero se procede con el borrado en el repositorio",
        );
      }

      return await this.videoRepository.delete(video, thumbnail);
    } catch (error) {
      console.error("Error borrando archivos:", error);
      throw new Error("Error al eliminar los archivos físicos del video");
    }
  }
}
