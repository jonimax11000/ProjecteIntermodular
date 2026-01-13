import { Router } from "express";
import { VideoRepositoryIntern } from "../../infraestructure/datasorces/intern/VideoRepositoryIntern";
import { VideoController } from "../controllers/videoController";
import { uploadVideo } from "../middlewares/multerMiddleware";
import { CreateVideoUseCase } from "../../domain/usecases/video/CreateVideoUseCase";
import { hlslMiddleware } from "../middlewares/hlslMiddleware";

const createController = () => {
  const repo = new VideoRepositoryIntern();  // ← Se crea CUANDO SE USA la ruta
  return new VideoController(
    new CreateVideoUseCase(repo)
  );
};

const videoRoutes = Router();

videoRoutes.post("/", uploadVideo.single('video'), hlslMiddleware, (req, res, next) => {
  createController().create(req, res, next);
});

/*videoRoutes.put("/:id", (req, res, next) => {
  createController().getById(req, res, next);  // ← Repository se crea aquí
});*/

export default videoRoutes;