# Documentación Técnica del Proyecto JustFlix

Este documento detalla la arquitectura, estructura de código y flujo de datos de la plataforma JustFlix. El sistema se compone de una arquitectura de microservicios con múltiples clientes (Web Admin y App Móvil).

---

## 🏗️ Visión General de la Arquitectura

El sistema opera con los siguientes componentes principales:

1.  **Clients**:
    *   **Admin Web (Vue 3)**: Panel de administración para subir vídeos y gestionar metadatos.
    *   **App Móvil (Flutter)**: Aplicación para el consumo de contenido por parte de los usuarios finales.
2.  **Services**:
    *   **Odoo (Python)**: Proveedor de Identidad (IdP), gestión de usuarios y suscripciones.
    *   **Express (Node.js)**: Servicio de Streaming, transcodificación de vídeo (FFmpeg) y WebSockets.
    *   **SpringBoot (Java)**: API REST para la gestión de metadatos (Catálogo, Series, Categorías).
    *   **Nginx**: Proxy inverso para Odoo y gestión de certificados SSL.

---

## 🖥️ 1. Clients/admin-web (Vue.js)

Aplicación SPA (Single Page Application) construida con **Vue 3** y **Vite**.

### A. Configuración del Proxy (`vite.config.js`)
Para evitar problemas de CORS y manejar certificados en desarrollo, Vite actúa como proxy:

```javascript
// vite.config.js
export default defineConfig({
  server: {
    proxy: {
      "/odoo-api": {
        target: "https://localhost:8069",
        changeOrigin: true,
        secure: false, // Acepta certificados autofirmados
        rewrite: (path) => path.replace(/^\/odoo-api/, ""),
      },
      "/node-api": {
        target: "https://localhost:3000/api",
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/node-api/, ""),
      },
      "/api": { // SpringBoot
        target: "https://localhost:8081",
        changeOrigin: true,
        secure: false,
      },
      "/ws": { // WebSockets
        target: "wss://localhost:3000",
        changeOrigin: true,
        secure: false,
        ws: true,
      },
    },
  },
});
```

### B. Servicios API con Interceptores (`src/services/api.js`)
Centraliza las llamadas HTTP usando instancias de `axios` e inyecta el token JWT automáticamente.

```javascript
// src/services/api.js

// 1. Instancia para SPRING BOOT
const JAVA_API = axios.create({
  baseURL: "/api",
  headers: { "Content-Type": "application/json" },
});

// Interceptor: Inyecta el Token
JAVA_API.interceptors.request.use((config) => {
    const token = localStorage.getItem("jwt_token");
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
});

// 2. Instancia para NODE (Uploads)
const NODE_API = axios.create({
  baseURL: "/node-api",
  headers: { "Content-Type": "multipart/form-data" },
});
// (Interceptor similar al de Java...)
```

---

## 📱 2. Clients/appMovil (Flutter)

Aplicación móvil construida con **Flutter** siguiendo **Clean Architecture**.

### A. Configuración HTTP Global (`main.dart`)
Dado que en desarrollo usamos certificados autofirmados, es necesario sobreescribir el `HttpOverrides` para evitar errores de SSL Handshake.

```dart
// lib/main.dart
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides(); // 👈 Aplicar override global
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}
```

### B. Cliente API Centralizado (`api_client.dart`)
Configuración de `Dio` (o `http` package) para manejar las peticiones a los microservicios.

```dart
// lib/config/api_client.dart
class ApiClient {
  static const String baseUrl = "https://10.0.2.2:8081/api"; // IP para Android Emulator

  // Método genérico con Auth Header
  Future<dynamic> get(String endpoint) async {
    final token = await _storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return _processResponse(response);
  }
}
```

---

## 🚀 3. Services/Express (Node.js)

Servicio encargado del manejo "pesado" de archivos multimedia y tiempo real.

### A. Servidor y WebSockets (`server.ts`)
Configuración híbrida para servir API REST y escuchar conexiones WebSocket en el mismo puerto.

```typescript
// src/app/http/server.ts
const app = express();
const server = https.createServer(httpsOptions, app);

// Inicializar WebSocket Server
const wss = new WebSocketServer({ noServer: true });

server.on('upgrade', (request, socket, head) => {
    wss.handleUpgrade(request, socket, head, (ws) => {
        wss.emit('connection', ws, request);
    });
});

server.listen(port, () => {
    console.log(`🚀 Servicio Express + WS corriendo en https://localhost:${port}`);
});
```

### B. Gestor de WebSockets (`WebSocketManager.ts`)
Permite enviar mensajes a clientes específicos (`unicast`) o a todos (`broadcast`).

```typescript
// src/app/http/websocket/WebSocketManager.ts
export class WebSocketManager {
    private static instance: WebSocketManager;
    private clients: Map<string, WebSocket> = new Map();

    public registerClient(clientId: string, ws: WebSocket) {
        this.clients.set(clientId, ws);
    }

    public notifyProgress(clientId: string, progress: number) {
        const client = this.clients.get(clientId);
        if (client && client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify({ type: 'PROGRESS', value: progress }));
        }
    }
}
```

---

## 🍃 4. Services/springboot (Java)

API REST principal para la lógica de negocio y persistencia de datos relacionales.

### A. Seguridad JWT (`SecurityConfig.java`)
Configura el servidor como un **Resource Server** que valida tokens firmados externamente (por Odoo).

```java
// src/main/java/.../security/SecurityConfig.java
@Bean
public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
        .csrf(AbstractHttpConfigurer::disable)
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/api/auth/**").permitAll() // Endpoints públicos
            .anyRequest().authenticated()              // El resto requiere Token
        )
        .oauth2ResourceServer(oauth2 -> oauth2
            .jwt(jwt -> jwt.decoder(jwtDecoder())) // Decodificador con clave pública
        );
    return http.build();
}
```

### B. Controlador REST (`VideoController.java`)
Ejemplo de endpoint protegido por roles.

```java
// src/main/java/.../controller/VideoController.java
@RestController
@RequestMapping("/api/cataleg")
public class VideoController {

    @PostMapping
    @PreAuthorize("#jwt.getClaimAsString('role') == 'admin'") // 👈 Solo Admins
    public ResponseEntity<VideoDTO> addVideo(@RequestBody VideoDTO video) {
        return ResponseEntity.ok(videoService.save(video));
    }
}
```

---

## 🟣 5. Services/Odoo (Python)

Actúa como el **Identity Provider (IdP)** central.

### A. Login y Generación de Token (`api_uth.py`)
Controlador personalizado que intercepta el login y emite un JWT.

```python
# extra-addons/odoo_jwt/controllers/api_uth.py
@http.route('/api/authenticate', type='json', auth='none', methods=['POST'])
def authenticate(self, **kwargs):
    # 1. Validar credenciales con Odoo Core
    uid = request.session.authenticate(db, login, password)
    if not uid: return {"error": "Credenciales inválidas"}

    # 2. Obtener datos de suscripción
    user = request.env['res.users'].browse(uid)
    subscription = request.env['subscription.subscription'].search([
        ('partner_id', '=', user.partner_id.id),
        ('state', '=', 'active')
    ], limit=1)

    # 3. Generar JWT
    token = JwtToken.generate_token(uid, extra_payload={
        'role': 'admin' if user.is_system else 'user',
        'sub_level': subscription.subscription_tier if subscription else None
    })

    return {'token': token}
```

---

## 🌐 6. Services/Nginx

Servidor Web y Proxy Inverso.

### A. Configuración Proxy (`default.conf`)
Maneja SSL y timeouts largos para Odoo.

```nginx
# conf.d/default.conf
server {
    listen 443 ssl;
    server_name localhost;

    ssl_certificate /etc/nginx/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/nginx/certs/nginx-selfsigned.key;

    # Aumentar límite para uploads grandes a Odoo
    client_max_body_size 100M;

    location / {
        proxy_pass http://odoo:8069;
        
        # Timeouts extendidos para operaciones pesadas
        proxy_read_timeout 720s;
        proxy_connect_timeout 720s;
        proxy_send_timeout 720s;
    }
}
```
