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
    let jobId: string | undefined;

    try {
      const file = (req as any).file;
      const { nivel } = req.body;
      console.log("req", req.body);
      console.log("nivel controller:", nivel);
      if (!file) {
        throw new Error('No video file uploaded');
      }

      const clientId = req.headers['x-client-id'] as string;
      const wsManager = (req as any).wsManager;

      jobId = `job_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

      if (clientId && wsManager) {
        wsManager.createJob(jobId, clientId);
        wsManager.sendByJobId(jobId, {
          type: 'processing_started',
          jobId,
          filename: file.filename,
          nivel: nivel,
          message: 'Iniciando procesamiento HLS',
          timestamp: new Date().toISOString()
        });
      }

      res.status(202).json({
        message: "Video aceptado para procesamiento",
        jobId,
        status: "processing"
      });

      setTimeout(async () => {
        try {
          const result = await this.createVideo.execute(
            file.filename,
            nivel,
            jobId,
            clientId,
          );
          console.log(`Video procesado: ${file.filename}`);

          this.eliminarVideoTemporal(file.filename);

        } catch (error) {
          console.error(`Error procesando ${file.filename}:`, error);
        }
      }, 0);

    } catch (err) {
      if (jobId && (req as any).wsManager) {
        (req as any).wsManager.notifyProcessingError(
          jobId,
          file?.filename || 'unknown',
          err instanceof Error ? err.message : 'Error desconocido'
        );
      }
      next(err);
    }
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