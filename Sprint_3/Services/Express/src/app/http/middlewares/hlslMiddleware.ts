import { Request, Response, NextFunction } from 'express';
import { VideoProcessor } from '../../infraestructure/services/videoProcessor';


export const hlslMiddleware = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    const processor = new VideoProcessor();
    await processor.processAllVideos();
    next();
};
