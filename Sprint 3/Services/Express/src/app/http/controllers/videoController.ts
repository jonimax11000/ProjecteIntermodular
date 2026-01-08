import { Request, Response, NextFunction } from "express";
import { CreateVideoUseCase } from "../../domain/usecases/vdeo/CreateVideoUseCase";



export class VideoController {
  constructor(
    private createVideo: CreateVideoUseCase,
  ) { }

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { title } = req.body;
      const video = req.file;
      const result = await this.createVideo.execute({ title, video });
      // const result = await this.createProduct.execute(req.body); // Així va en users però no aci...
      res.status(201).json(result);
    } catch (err) { next(err); }
  }
}