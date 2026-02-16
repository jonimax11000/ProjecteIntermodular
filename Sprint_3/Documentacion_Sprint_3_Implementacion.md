# Documentación Sprint 3: Implementación Inicial de Servicios y Prototipos UI

Este documento detalla la implementación técnica del **Sprint 3**, incluyendo ejemplos de código real extraídos del proyecto.

## 🎯 Objetivo General

Tener una primera versión funcional del backend (CRUD básico, uploads) y prototipos navegables en los clientes.

---

## 1. Backend — Catálogo (Spring Boot)

Implementación del CRUD básico de videos y validación de seguridad.

### A. CRUD de Videos (`VideoController.java`)

El controlador expone endpoints REST para la gestión de vídeos. Nótese el uso de `@PreAuthorize` para proteger acciones de escritura (Admin) y el acceso público de lectura.

```java
// Services/springboot/.../controller/VideoController.java
@Controller
public class VideoController {
    @Autowired
    private VideoService videoService;

    // Endpoint PÚBLICO para listar el catálogo
    @GetMapping("/api/cataleg")
    @ResponseBody
    public List<VideoDTO> getCataleg() {
        return videoService.getAllVideos();
    }

    // Endpoint PÚBLICO para obtener un video por ID
    @GetMapping("/api/cataleg/{id}")
    @ResponseBody
    public VideoDTO getCatalegById(@PathVariable Long id) {
        return videoService.getVideoById(id);
    }

    // Endpoint PROTEGIDO (Solo Admin) para añadir videos
    @PostMapping("/api/cataleg")
    @PreAuthorize("#jwt.getClaimAsString('role') == 'admin'") // Validación de Rol desde el JWT
    public ResponseEntity<VideoDTO> addVideo(@RequestBody VideoDTO newVideo, @AuthenticationPrincipal Jwt jwt) {
        try {
            videoService.saveVideo(newVideo);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    // Endpoint PROTEGIDO (Solo Admin) para borrar videos
    @DeleteMapping("/api/cataleg/{id}")
    @PreAuthorize("#jwt.getClaimAsString('role') == 'admin'")
    public ResponseEntity<String> deleteVideo(@PathVariable Long id, @AuthenticationPrincipal Jwt jwt) {
        videoService.deleteVideo(id);
        return new ResponseEntity<>("Video borrado satisfactoriamente", HttpStatus.OK);
    }
}
```

### B. Validación de Seguridad (Spring Security)

Spring Boot actúa como **Resource Server** (OAuth2), validando la firma del JWT emitido por Odoo. La configuración asegura que el token sea válido antes de llegar al controlador.

---

## 2. Backend — Media Server (ExpressJS)

Servidor encargado de la recepción de archivos físicos.

### A. Endpoint de Upload (`videoRoutes.ts`)

Ruta que recibe el archivo mediante `POST`, utiliza un middleware para gestionar la subida y devuelve una respuesta inmediata con el ID/Nombre para que el cliente pueda asociarlo.

```typescript
// Services/Express/.../routes/videoRoutes.ts
import { Router } from "express";
import { uploadVideo } from "../middlewares/multerMiddleware";
import { jwtMiddlewareAdmin } from "../middlewares/jwtMiddleware";
// ... imports

const videoRoutes = Router();

videoRoutes.post(
  "/",
  jwtMiddlewareAdmin, // 1. Valida que el usuario sea Admin (Token Odoo)
  uploadVideo.single("video"), // 2. Multer procesa la subida del archivo 'video'
  (req, res, next) => {
    // En Sprint 3, lo critico es que 'req.file' ya contiene el archivo guardado.
    // req.file.filename contiene el nombre con el que se guardó.
    const wsManager = (req as any).wsManager;

    // Se llama al controlador para iniciar (o simular) procesamiento
    createController(wsManager).create(req, res, next);
  },
);
```

### B. Almacenamiento Físico (`multerMiddleware.ts`)

Configuración de `multer` para guardar el archivo en el disco local y devolver su nombre.

```typescript
// Services/Express/.../middlewares/multerMiddleware.ts
import multer from "multer";
import * as path from "path";

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    // Guarda físicamente en esta ruta local
    cb(null, path.join(__dirname, "../../data/videos"));
  },
  filename: (_req, file, cb) => {
    // Mantiene el nombre original del archivo
    cb(null, file.originalname);
  },
});

// Filtro simple para asegurar que es video
const videoFilter = (_req, file, cb) => {
  const allowedVideoTypes = [
    "video/mp4",
    "video/webm",
    "video/ogg",
    "video/avi",
    "video/mov",
  ];
  if (allowedVideoTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error("Solo se permiten archivos de video"), false);
  }
};

export const uploadVideo = multer({
  storage: storage,
  fileFilter: videoFilter,
});
```

---

## 3. Portal Web (Odoo) - Autenticación

El módulo `odoo_jwt` expone una API para loguearse desde clientes externos.

### API Login (`api_uth.py`)

Recibe credenciales, autentica contra Odoo y genera un **JWT** enriquecido con roles y suscripciones.

```python
# Services/Odoo/extra-addons/odoo_jwt/controllers/api_uth.py
class ApiAuth(http.Controller):

    @http.route('/api/authenticate', type='json', auth='none', methods=['POST'])
    def authenticate_post(self, **kwargs):
        # 1. Obtener parámetros
        params = request.jsonrequest.get('params', {})
        login = params.get('login')
        password = params.get('password')
        db_name = params.get('db')

        # 2. Autenticación nativa de Odoo
        uid = request.session.authenticate(db_name, login, password)

        if not uid:
            return {"error": "Invalid login or password"}

        # 3. Obtener info extra (Roles, Suscripción)
        user = request.env['res.users'].browse(uid)
        user_info = self._get_user_info(uid) # Método helper que busca suscripción activa

        # 4. Generación de JWT con Payload personalizado
        access_token = JwtToken.generate_token(uid, extra_payload={
            'uid': uid,
            'email': user.login,
            'role': user_info['role'], # 'admin' o 'user'
            'has_subscription': user_info['has_subscription'],
            'subscription_level': user_info['subscription_level']
        })

        refresh_token = JwtToken.create_refresh_token(request, uid)

        # 5. Retorno de tokens al cliente
        return {
            'token': access_token,
            'refreshToken': refresh_token,
            'short_term_token_span': JwtToken.ACCESS_TOKEN_SECONDS
        }
```

---

## 4. Clientes - Prototipos UI

### A. App Móvil (Flutter)

**Login Screen (`login_screen.dart`):**
Pantalla funcional que captura email/password y llama a la API de Odoo.

```dart
// Clients/appMovil/.../login_screen.dart
Future<void> _login(String email, String password) async {
  // Configurar cliente (ignorando SSL autofirmado para dev)
  final ioc = HttpClient();
  ioc.badCertificateCallback = (cert, host, port) => true;
  final client = IOClient(ioc);

  // Petición HTTP a Odoo
  final response = await client.post(
    Uri.parse(ApiConfig.urls["login"]!),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "params": {"login": email, "password": password, "db": "Justflix"}
    }),
  );

  // Procesar respuesta
  final data = jsonDecode(response.body);

  if (data['result'] != null && data['result']['token'] != null) {
      final String accessToken = data['result']['token'];
      final String refreshToken = data['result']['refreshToken'];

      // Guardar sesión segura en el dispositivo
      final sessionService = SessionService(const FlutterSecureStorage());
      await sessionService.saveSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: ...
      );

      // Navegar a Home
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  } else {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login error")));
  }
}
```

**Grid de Videos (`videos_screen.dart`):**
Muestra la lista de vídeos obtenidos del backend (Spring Boot).

```dart
// Clients/appMovil/.../videos_screen.dart
class _VideosScreenState extends State<VideosScreen> {
  // ...
  Future<void> _loadVideos() async {
      // Llama al caso de uso 'GetVideos' que usa el repositorio
      final result = await getVideos();
      setState(() { videos = result; });
  }

  @override
  Widget build(BuildContext context) {
    // ...
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, index) {
          // Renderiza cada tarjeta de video
          return VideoGridCard(video: filteredVideos![index]);
        }
    );
  }
}
```

### B. Web Admin (Vue.js)

**Login View (`LoginView.vue`):**
Formulario de acceso para administradores.

```javascript
// Clients/admin-web/.../LoginView.vue
const handleLogin = async () => {
  try {
    isLoading.value = true;
    // Llamada al servicio API (Axios configurado en api.js)
    // api.login llama a /odoo-api/api/authenticate
    const dataOdoo = await api.login(username.value, password.value);

    // Guardar Token y datos de usuario en LocalStorage
    localStorage.setItem("jwt_token", dataOdoo.token);
    localStorage.setItem("refresh_token", dataOdoo.refreshToken);
    localStorage.setItem("user", username.value);

    // Redirigir al panel principal
    router.push("/lista");
  } catch (e) {
    error.value = "Usuario o contraseña incorrectos";
  } finally {
    isLoading.value = false;
  }
};
```
