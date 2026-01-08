import multer, { FileFilterCallback } from 'multer';
import { Request } from 'express';
import * as path from 'path';
import { fileURLToPath } from 'url';

// Define __dirname para ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Tipos MIME de video permitidos
const allowedVideoTypes = ['video/mp4', 'video/webm', 'video/ogg', 'video/avi', 'video/mov']; //

// Configuración del almacenamiento en disco
const storage = multer.diskStorage({
    destination: (_req: Request, _file: Express.Multer.File, cb) => {
        // Asegúrate de que la carpeta '' exista
        cb(null, path.join(__dirname, '../../data/videos'));
    },
    filename: (_req: Request, file: Express.Multer.File, cb) => {
        // Nombre de archivo personalizado para evitar conflictos
        const fileName = _req.body.title.toLowerCase().replace(/\s+/g, '') + ".mp4";
        cb(null, fileName);
    },
});

// Función de filtro de archivos
const videoFilter = (_req: Request, file: Express.Multer.File, cb: FileFilterCallback) => {
    if (allowedVideoTypes.includes(file.mimetype)) {
        // Acepta el archivo
        cb(null, true);
    } else {
        // Rechaza el archivo y opcionalmente añade un error a la petición
        const error = new Error('Solo se permiten archivos de video (mp4, webm, ogg, avi, mov)');
        // Puedes adjuntar el error a la petición para manejarlo después
        (_req as any).fileValidationError = error;
        cb(error, false);
    }
};

// Inicializa Multer con la configuración y el filtro
export const uploadVideo = multer({
    storage: storage,
    fileFilter: videoFilter
});