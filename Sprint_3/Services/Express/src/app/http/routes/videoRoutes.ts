import { Router } from "express";
import { VideoRepositoryIntern } from "../../infraestructure/datasorces/intern/VideoRepositoryIntern";
import { VideoController } from "../controllers/videoController";
import { uploadVideo } from "../middlewares/multerMiddleware";
import { CreateVideoUseCase } from "../../domain/usecases/video/CreateVideoUseCase";
import { hlslMiddleware } from "../middlewares/hlslMiddleware";
import { DeleteVideoUseCase } from "../../domain/usecases/video/DeleteVideoUsecase";

const createController = () => {
  const repo = new VideoRepositoryIntern();  // ← Se crea CUANDO SE USA la ruta
  return new VideoController(
    new CreateVideoUseCase(repo),
    new DeleteVideoUseCase(repo)
  );
};

const videoRoutes = Router();

videoRoutes.post("/", uploadVideo.single('video'), hlslMiddleware, (req, res, next) => {
  createController().create(req, res, next);
});

videoRoutes.delete("/", (req, res, next) => {
  createController().delete(req, res, next);  // ← Repository se crea aquí
});

export default videoRoutes;