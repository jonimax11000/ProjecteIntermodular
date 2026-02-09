import { Router } from "express";
import { VideoRepositoryIntern } from "../../infraestructure/datasorces/intern/VideoRepositoryIntern";
import { VideoController } from "../controllers/videoController";
import { uploadVideo } from "../middlewares/multerMiddleware";
import { CreateVideoUseCase } from "../../domain/usecases/video/CreateVideoUseCase";
import { jwtMiddlewareAdmin } from "../middlewares/jwtMiddleware";

import { DeleteVideoUseCase } from "../../domain/usecases/video/DeleteVideoUsecase";

const createController = (wsManager?: any) => {
  const repo = new VideoRepositoryIntern();  // ← Se crea CUANDO SE USA la ruta
  return new VideoController(
    new CreateVideoUseCase(repo, wsManager),
    new DeleteVideoUseCase(repo)
  );
};

const videoRoutes = Router();

videoRoutes.post("/", jwtMiddlewareAdmin, uploadVideo.single('video'), (req, res, next) => {
  const wsManager = (req as any).wsManager;
  createController(wsManager).create(req, res, next);
});

videoRoutes.delete("/", jwtMiddlewareAdmin, (req, res, next) => {
  createController().delete(req, res, next);  // ← Repository se crea aquí
});

export default videoRoutes;