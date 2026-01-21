import { WebSocket } from 'ws';

export class WebSocketManager {
    private clients = new Map<string, WebSocket>(); // clientId -> WebSocket
    private jobs = new Map<string, string>(); // jobId -> clientId

    registerClient(clientId: string, ws: WebSocket): void {
        this.clients.set(clientId, ws);
        console.log(`Cliente registrado: ${clientId} (total: ${this.clients.size})`);
    }

    unregisterClient(clientId: string): void {
        this.clients.delete(clientId);
        console.log(`Cliente removido: ${clientId}`);
    }

    createJob(jobId: string, clientId: string): void {
        this.jobs.set(jobId, clientId);
        console.log(`Job creado: ${jobId} para cliente ${clientId}`);
    }

    completeJob(jobId: string): void {
        this.jobs.delete(jobId);
        console.log(`Job completado: ${jobId}`);
    }

    sendToClient(clientId: string, message: any): boolean {
        const ws = this.clients.get(clientId);
        if (!ws || ws.readyState !== WebSocket.OPEN) {
            return false;
        }

        try {
            ws.send(JSON.stringify(message));
            return true;
        } catch (error) {
            console.error(`Error enviando a ${clientId}:`, error);
            return false;
        }
    }

    sendByJobId(jobId: string, message: any): boolean {
        const clientId = this.jobs.get(jobId);
        if (!clientId) {
            console.warn(`Job ${jobId} no tiene cliente asociado`);
            return false;
        }

        return this.sendToClient(clientId, {
            ...message,
            jobId
        });
    }

    notifyProcessingStarted(jobId: string, filename: string): void {
        console.log(`Notificando inicio para job ${jobId}`);
        this.sendByJobId(jobId, {
            type: 'processing_started',
            jobId,
            filename,
            message: 'Procesamiento iniciado',
            timestamp: new Date().toISOString()
        });
    }

    notifyProcessingCompleted(
        jobId: string,
        filename: string,
        videoData: any
    ): void {
        console.log(`Notificando completado para job ${jobId}`);

        this.sendByJobId(jobId, {
            type: 'processing_completed',
            jobId,
            filename,
            videoData: videoData,
            message: 'Video procesado exitosamente',
            timestamp: new Date().toISOString()
        });
    }

    notifyProcessingError(jobId: string, filename: string, error: string): void {
        console.log(`Notificando error para job ${jobId}: ${error}`);

        this.sendByJobId(jobId, {
            type: 'processing_error',
            jobId,
            filename,
            error: error,
            message: 'Error procesando el video',
            timestamp: new Date().toISOString()
        });
    }
}