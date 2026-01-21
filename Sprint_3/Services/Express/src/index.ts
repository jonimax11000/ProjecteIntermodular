import { buildServer } from './app/http/server.js';

async function startServer() {
  try {

    const app = buildServer();
    const PORT = process.env.PORT || 3000;

    app.listen(PORT, () => {
      console.log(`Servidor ejecutándose en http://localhost:${PORT}`);
      console.log(`Thumbnails disponibles en: http://localhost:${PORT}/api/thumbnails/`);
      console.log(`Videos HLS disponibles en: http://localhost:${PORT}/api/videos/`);
    });
  } catch (error) {
    console.error('Error al iniciar el servidor:', error);
    process.exit(1);
  }
}

startServer();