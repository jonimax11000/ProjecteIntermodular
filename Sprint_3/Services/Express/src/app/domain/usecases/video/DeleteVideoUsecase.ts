import path from "path";
import fs from "fs";
import { IVideoRepository } from "../../../domain/repositories/IVideoRepository";

export class DeleteVideoUseCase {

    private readonly videosPublicPath = './src/app/public/';
    private readonly thumbnailsPublicPath = './src/app/public/';

    constructor(private videoRepository: IVideoRepository) { }

    async execute(video: string, thumbnail: string): Promise<string> {
        const cwd = process.cwd();

        const cleanVideoPath = video.startsWith('/') ? video.slice(1) : video;
        const cleanThumbnailPath = thumbnail.startsWith('/') ? thumbnail.slice(1) : thumbnail;

        const fullVideoPath = path.join(cwd, this.videosPublicPath, cleanVideoPath);
        const fullThumbnailPath = path.join(cwd, this.thumbnailsPublicPath, cleanThumbnailPath);

        const videoDir = path.dirname(fullVideoPath);

        console.log(`Intentando borrar videoDir: ${videoDir}`);
        console.log(`Intentando borrar thumbnail: ${fullThumbnailPath}`);

        if (!fs.existsSync(videoDir) || !fs.existsSync(fullThumbnailPath)) {
            console.error(`Video o thumbnail no encontrado`);
            return "No se ha podido eliminar el video, prueba la eliminación manual";
        }

        try {
            if (fs.existsSync(videoDir)) {
                fs.rmSync(videoDir, { recursive: true, force: true });
                console.log(`Carpeta eliminada: ${videoDir}`);
            }

            if (fs.existsSync(fullThumbnailPath)) {
                fs.unlinkSync(fullThumbnailPath);
                console.log(`Thumbnail eliminado: ${fullThumbnailPath}`);
            }

            return await this.videoRepository.delete(video, thumbnail);
        } catch (error) {
            console.error("Error borrando archivos:", error);
            throw new Error("Error al eliminar los archivos físicos del video");
        }
    }
}