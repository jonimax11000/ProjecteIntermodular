import { IVideoRepository } from "../../repositories/IVideoRepository";
import fs from 'fs';
import path from "path";


export class DeleteVideoUseCase {

    private readonly publicPath = './src/app';

    constructor(private videoRepository: IVideoRepository) { }

    async execute(video: String, thumbnail: String): Promise<String> {
        try {
            if (await this.eliminarVideo(video) === "Video not found") return "Video not found";
            if (await this.eliminarThumbnail(thumbnail) === "Thumbnail not found") return "Thumbnail not found";
            await this.videoRepository.delete(video, thumbnail);
            return "Video deleted successfully";
        } catch (error) {
            throw error;
        }
    }

    private async eliminarVideo(video: String): Promise<String> {
        try {
            let pathVideo = path.join(process.cwd(), `${this.publicPath}/public${video}`);
            pathVideo = path.dirname(pathVideo);
            if (fs.existsSync(pathVideo)) {
                fs.readdirSync(pathVideo).forEach((file) => {
                    fs.unlinkSync(path.join(pathVideo, file));
                });
                fs.rmdirSync(pathVideo);
                return "Video deleted successfully";
            }
            else {
                return "Video not found";
            }
        } catch (error) {
            throw error;
        }
    }

    private async eliminarThumbnail(thumbnail: String): Promise<String> {
        try {
            const pathThumbnail = path.join(process.cwd(), `${this.publicPath}/public${thumbnail}`);
            if (fs.existsSync(pathThumbnail)) {
                fs.unlinkSync(pathThumbnail);
                return "Thumbnail deleted successfully";
            }
            else {
                return "Thumbnail not found";
            }
        } catch (error) {
            throw error;
        }
    }
}