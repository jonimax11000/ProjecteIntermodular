import express, { NextFunction, Request, Response } from "express";
import videoRoutes from "./routes/videoRoutes";
import path from "path";
import { fileURLToPath } from "url";
import cors from "cors";
import { WebSocketServer } from "ws";
import https from "https"; // Cambiado de http a https
import http from "http"; // Mantenemos http para redireccionar HTTP a HTTPS
import fs from "fs"; // Necesario para leer el certificado
import { WebSocketManager } from "./websocket/WebSocketManager";
import { setupWebSocketHandler } from "./websocket/WebSocketHandler";
import { jwtMiddleware, jwtMiddlewareUser } from "./middlewares/jwtMiddleware";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export function buildServer() {
  const app = express();
  app.use(express.json());

  const corsOptions = {
    origin: (origin: string | undefined, callback: any) => {
      if (!origin) {
        callback(null, '*');
      } else {
        callback(null, origin);
      }
    },
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization", "X-Requested-With", "X-Client-ID"],
    credentials: true,
  };
  app.use(cors(corsOptions));

  // Redirección de HTTP a HTTPS (opcional, pero recomendado)
  app.use((req: Request, res: Response, next: NextFunction) => {
    if (!req.secure && req.protocol !== 'https') {
      return res.redirect(`https://${req.headers.host}${req.url}`);
    }
    next();
  });

  // Websocket
  const wsManager = new WebSocketManager();
  const wss = new WebSocketServer({ noServer: true });
  setupWebSocketHandler(wss, wsManager);

  const publicPath = path.join(__dirname, '../../app/public');

  app.use('/api/thumbnails', express.static(path.join(publicPath, 'thumbnails')));
  app.use(jwtMiddleware);
  app.use('/api/videos', jwtMiddlewareUser, express.static(path.join(publicPath, 'videos')));

  app.use((req: Request, res: Response, next: NextFunction) => {
    (req as any).wsManager = wsManager;
    next();
  });

  app.use("/api/video", videoRoutes);

  app.use((req: Request, res: Response) => {
    res.status(404).json({ message: "Resource not found" });
  });

  app.use((err: any, req: Request, res: Response, next: NextFunction) => {
    console.error(err);
    const status = err.status || 500;
    res.status(status).json({
      error: true,
      message: err.message || "Internal server error",
    });
  });

  // Configuración HTTPS
  const httpsOptions = {
    pfx: fs.readFileSync(path.join(__dirname, '../../../justflix.p12')), // Ajusta la ruta
    passphrase: '0709200025042009@Jdsf', // La que usaste al crear el certificado
  };

  // Crear servidor HTTPS
  const httpsServer = https.createServer(httpsOptions, app);

  // Configurar WebSocket en el servidor HTTPS
  httpsServer.on('upgrade', (request, socket, head) => {
    const { url } = request;

    if (url === '/ws') {
      wss.handleUpgrade(request, socket, head, (ws) => {
        wss.emit('connection', ws, request);
      });
    } else {
      socket.destroy();
    }
  });

  // Retornar ambos servidores si necesitas ambos
  return {
    https: httpsServer
  };
}