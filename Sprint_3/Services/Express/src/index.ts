import { buildServer } from './app/http/server.js';
import * as fs from 'fs';
import * as process from 'process';

async function startServer() {
  try {

    const { https: httpsServer } = buildServer();
    const PORT = process.env.PORT || 3000;

    httpsServer.listen(PORT, () => {
      console.log(`Servidor ejecutándose en https://localhost:${PORT}`);
      console.log(`Thumbnails disponibles en: https://localhost:${PORT}/api/thumbnails/`);
      console.log(`Videos HLS disponibles en: https://localhost:${PORT}/api/videos/`);
    });
  } catch (error) {
    console.error('Error al iniciar el servidor:', error);
    process.exit(1);
  }
}

startServer();