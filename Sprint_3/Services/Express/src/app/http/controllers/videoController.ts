import { Request, Response, NextFunction } from "express";
import { CreateVideoUseCase } from "../../domain/usecases/video/CreateVideoUseCase";
import path from "path";
import fs from "fs";
import { DeleteVideoUseCase } from "../../domain/usecases/video/DeleteVideoUsecase";


export class VideoController {
  constructor(
    private createVideo: CreateVideoUseCase,
    private deleteVideo: DeleteVideoUseCase
  ) { }

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const file = (req as any).file;
      if (!file) {
        throw new Error('No video file uploaded'); // Or handle appropriately
      }

      const result = await this.createVideo.execute(file.filename);
      res.status(201).json(result);

      this.eliminarVideoTemporal(file.filename);

    } catch (err) { next(err); }
  }

  delete = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { video, thumbnail } = req.body;
      if (!video || !thumbnail) {
        throw new Error('No video file uploaded'); // Or handle appropriately
      }

      const result = await this.deleteVideo.execute(video, thumbnail);

      if (result === "Video eliminado correctamente") {
        res.status(201).json(result);
      } else {
        res.status(400).json(result);
      }

    } catch (err) { next(err); }
  }

  private eliminarVideoTemporal(filename: string) {
    const cwd = process.cwd();
    const filePath = path.join(cwd, "./src/app/data/videos", filename);

    if (fs.existsSync(filePath)) {
      try {
        fs.unlinkSync(filePath);
        console.log(`Eliminado: ${filePath}`);
      } catch (err) {
        console.error(`Error eliminando ${filePath}:`, err);
      }
    }
  }
}