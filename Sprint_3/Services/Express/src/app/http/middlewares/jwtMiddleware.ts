import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import process from 'process';
import { readFileSync } from 'fs';
import path from 'path';


export const jwtMiddleware = (req: Request, res: Response, next: NextFunction) => {
    // Intentar obtener token del header Authorization o del query parameter
    let token = req.headers.authorization?.split(' ')[1];
    console.log("token: "+token);
    
    if (!token) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
    try {
        const publicKeyPath = process.env.JWT_PUBLIC_KEY_PATH;
        console.log("publicKeyPath: "+publicKeyPath);
        if (!publicKeyPath) {
            throw new Error('Public key not found');
        }
        const publicKey = readFileSync(publicKeyPath);
        console.log("publicKey: "+publicKey);
        const decoded = jwt.verify(token, publicKey);
        console.log("decoded: "+decoded);
        req.body = req.body || {};
        req.body.decoded = decoded;
        console.log("req.body: "+req.body);
        next();
    } catch (error) {
        console.log("error: "+error);
        return res.status(401).json({ message: 'Unauthorized' });
    }
}

export const jwtMiddlewareAdmin = (req: Request, res: Response, next: NextFunction) => {
    const role = req.body.decoded.role;
    if (!role) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
    try {
        if (role !== 'admin') {
            return res.status(401).json({ message: 'Unauthorized' });
        }
        next();
    } catch (error) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
}

export const jwtMiddlewareUser = (req: Request, res: Response, next: NextFunction) => {
    const role = req.body.decoded.role;
    const active = req.body.decoded.active;
    const subscription_level = req.body.decoded.subscription_level;
    const level = req.path;
    const paths = level.split('/');
    const nivel = paths[1];
    if (!role) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
    try {
        if ((role == 'user' || role == 'admin') && active && subscription_level >= nivel) {
            next();
        }
        else {
            return res.status(401).json({ message: 'Unauthorized' });
        }
    } catch (error) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
}

