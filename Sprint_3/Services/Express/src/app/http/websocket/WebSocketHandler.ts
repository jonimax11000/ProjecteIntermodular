import { WebSocketServer, WebSocket } from 'ws';
import { WebSocketManager } from './WebSocketManager';

export function setupWebSocketHandler(
    wss: WebSocketServer,
    wsManager: WebSocketManager
) {
    wss.on('connection', (ws: WebSocket, req) => {
        const ip = req.socket.remoteAddress;
        console.log(`Nueva conexión WebSocket desde: ${ip}`);

        ws.send(JSON.stringify({
            type: 'welcome',
            message: 'Conectado al servicio de procesamiento de videos',
            timestamp: new Date().toISOString()
        }));

        ws.on('message', (raw: Buffer) => {
            try {
                const data = raw.toString();

                if (!data || data.trim() === '') {
                    console.log('Mensaje vacío recibido');
                    return;
                }

                const message = JSON.parse(data);
                console.log(`Mensaje recibido de ${ip}:`, message);

                if (message.type === 'register' && message.clientId) {
                    const clientId = message.clientId.trim();
                    wsManager.registerClient(clientId, ws);

                    ws.send(JSON.stringify({
                        type: 'registered',
                        clientId,
                        message: 'Registro exitoso',
                        timestamp: new Date().toISOString()
                    }));

                    console.log(`Cliente identificado: ${clientId}`);
                } else if (message.type === 'ping') {
                    ws.send(JSON.stringify({
                        type: 'pong',
                        timestamp: new Date().toISOString()
                    }));
                } else {
                    console.warn(`Tipo de mensaje desconocido: ${message.type}`);
                }
            } catch (error) {
                console.error('Error procesando mensaje WebSocket:', error);
                console.log('Datos recibidos:', raw.toString());

                ws.send(JSON.stringify({
                    type: 'error',
                    message: 'Formato de mensaje inválido. Envía JSON válido.',
                    timestamp: new Date().toISOString()
                }));
            }
        });

        ws.on('close', () => {
            console.log(`🔌 Conexión WebSocket cerrada: ${ip}`);
        });

        ws.on('error', (error) => {
            console.error(`Error en WebSocket ${ip}:`, error);
        });
    });
}