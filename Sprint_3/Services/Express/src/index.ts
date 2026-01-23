import { buildServer } from './app/http/server.js';
import * as fs from 'fs';
import * as process from 'process';

async function startServer() {
  try {

    const app = buildServer();
    const PORT = process.env.PORT || 3000;
    const publicKeyPath = process.env.JWT_PUBLIC_KEY_PATH;
    const publicKey = fs.readFileSync(publicKeyPath, 'utf8');

    console.log('Clave pública cargada:', publicKey);

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