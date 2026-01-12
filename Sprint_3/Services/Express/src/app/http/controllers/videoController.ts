import { Request, Response, NextFunction } from "express";
import { CreateVideoUseCase } from "../../domain/usecases/video/CreateVideoUseCase";
import path from "path";
import fs from "fs";



export class VideoController {
  constructor(
    private createVideo: CreateVideoUseCase,
  ) { }

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await this.createVideo.execute();
      // const result = await this.createProduct.execute(req.body); // Així va en users però no aci...
      res.status(201).json(result);
      this.eliminarVideosTemporales();
    } catch (err) { next(err); }
  }

  private eliminarVideosTemporales() {
    const cwd = process.cwd();
    const directory = path.join(cwd, "./src/app/data/videos");

    if (fs.existsSync(directory)) {
      const files = fs.readdirSync(directory);
      for (const file of files) {
        const filePath = path.join(directory, file);
        try {
          fs.unlinkSync(filePath);
          console.log(`Eliminado: ${filePath}`);
        } catch (err) {
          console.error(`Error eliminando ${filePath}:`, err);
        }
      }
    }
  }
}