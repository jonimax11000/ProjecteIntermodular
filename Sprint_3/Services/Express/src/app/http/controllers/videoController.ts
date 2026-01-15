import { Request, Response, NextFunction } from "express";
import { CreateVideoUseCase } from "../../domain/usecases/video/CreateVideoUseCase";
import path from "path";
import fs from "fs";
import { DeleteVideoUseCase } from "../../domain/usecases/video/DeleteVideoUseCase";


export class VideoController {
  constructor(
    private createVideo: CreateVideoUseCase,
    private deleteVideo: DeleteVideoUseCase,
  ) { }

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const file = (req as any).file;
      if (!file) {
        throw new Error("No file uploaded");
      }
      const result = await this.createVideo.execute(file.filename);
      // const result = await this.createProduct.execute(req.body); // Així va en users però no aci...
      res.status(201).json(result);
      this.eliminarVideoTemporal(file.filename);
    } catch (err) { next(err); }
  }

  delete = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await this.deleteVideo.execute(req.body.video, req.body.thumbnail);
      if (result === "Video deleted successfully") {
        res.status(200).json({ message: result });
      } else {
        res.status(404).json({ message: result });
      }
    } catch (err) { next(err); }
  }

  private eliminarVideoTemporal(filename: string) {
    const cwd = process.cwd();
    const filePath = path.join(cwd, "./src/app/data/videos", filename);

    try {
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
        console.log(`Eliminado: ${filePath}`);
      }
    } catch (err) {
      console.error(`Error eliminando ${filePath}:`, err);
    }
  }
}