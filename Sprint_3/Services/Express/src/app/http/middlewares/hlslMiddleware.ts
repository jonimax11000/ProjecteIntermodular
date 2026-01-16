import { Request, Response, NextFunction } from 'express';
import { VideoProcessor } from '../../infraestructure/services/videoProcessor';
import 'multer';


export const hlslMiddleware = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    const processor = new VideoProcessor();
    const file = (req as any).file;
    if (file) {
        await processor.processVideo(file.filename);
    }
    next();
};
