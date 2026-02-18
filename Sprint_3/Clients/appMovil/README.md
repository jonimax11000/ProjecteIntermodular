# 📱 JustFlix — App Móvil Flutter

Aplicación móvil desarrollada en **Flutter** que sigue el patrón de **Clean Architecture** para consumir tres backends distintos:

| Backend | Tecnología | Puerto | Función |
|---------|-----------|--------|---------|
| **Autenticación** | Odoo | `:8069` | Login, registro, gestión de tokens JWT |
| **Catálogo** | Spring Boot | `:8081` | Listado de vídeos, series y categorías |
| **Streaming** | Express | `:3000` | Reproducción de vídeo |

---

## 📁 Estructura del proyecto

```
lib/
├── main.dart
├── config/                        ← Configuración global
│   ├── api_config.dart
│   └── api_client.dart
└── features/
    ├── core/                      ← Servicios transversales
    │   ├── api_client.dart
    │   ├── authenticated_http_client.dart
    │   ├── session_service.dart
    │   └── service_locator.dart
    ├── domain/                    ← Capa de dominio (reglas de negocio)
    │   ├── entities/
    │   │   ├── video.dart
    │   │   ├── series.dart
    │   │   └── categorias.dart
    │   ├── repositories/
    │   │   ├── videos_repository.dart
    │   │   ├── series_repository.dart
    │   │   └── categorias_repository.dart
    │   └── usecases/
    │       ├── get_videos.dart
    │       ├── get_series.dart
    │       └── get_categorias.dart
    ├── data/                      ← Capa de datos (implementaciones)
    │   ├── datasources/
    │   │   ├── videos_api.dart
    │   │   ├── series_api.dart
    │   │   └── categorias_api.dart
    │   ├── mappers/
    │   │   ├── video_mapper.dart
    │   │   ├── series_mapper.dart
    │   │   └── categoria_mapper.dart
    │   └── repositories/
    │       ├── videos_repository_impl.dart
    │       ├── series_repository_impl.dart
    │       └── categorias_repository_impl.dart
    └── presentation/              ← Capa de presentación (UI)
        ├── login_screen.dart
        ├── provider/
        │   └── wishlist_notifier.dart
        ├── menu/
        │   ├── home_screen.dart
        │   ├── screens/
        │   │   ├── videos_screen.dart
        │   │   ├── video_player_screen.dart
        │   │   ├── series_screen.dart
        │   │   └── series_detall_screen.dart
        │   └── widgets/
        ├── videoList/
        │   └── videoList_screen.dart
        └── search/
            └── search_screen.dart
```

---

## 🏗️ Clean Architecture

La aplicación sigue el patrón **Clean Architecture** separando el código en tres capas independientes:

### 1. Domain (Dominio)

Es la capa **más interna** y no depende de ninguna otra. Define las reglas de negocio puras.

#### Entities

Clases simples que representan los objetos de negocio:

```dart
// domain/entities/video.dart
class Video {
  final int id;
  final String titol;
  final String videoURL;
  final String thumbnailURL;
  final String duracio;
  final String? descripcio;
  final int? serie;
  final int? edat;
  final int? nivell;
  final List<int>? categories;
}
```

Otras entidades: `Series` (id, nom, temporada, videosIds) y `Categorias` (id, categoria, videosIds).

#### Repositories (abstractos)

Interfaces que definen **qué** operaciones se pueden hacer, sin decir **cómo**:

```dart
// domain/repositories/videos_repository.dart
abstract class VideosRepository {
  Future<List<Video>> getVideos();
  Future<List<Video>> getVideosBySerie(int serieId);
  Future<List<Video>> getVideosByName(String name);
}
```

#### Use Cases

Cada caso de uso encapsula una única acción de negocio. Reciben un repositorio por constructor (inyección de dependencias):

```dart
// domain/usecases/get_videos.dart
class GetVideos {
  final VideosRepository repository;
  GetVideos(this.repository);

  Future<List<Video>> call() async => await repository.getVideos();
  Future<List<Video>> callBySerie(int serieId) async => await repository.getVideosBySerie(serieId);
  Future<List<Video>> callByName(String name) async => await repository.getVideosByName(name);
}
```

---

### 2. Data (Datos)

Implementa las interfaces del dominio y se encarga de la comunicación con los backends.

#### Datasources

Realizan las peticiones HTTP reales a las APIs. Utilizan `ApiClient.client` (que incluye autenticación automática):

```dart
// data/datasources/videos_api.dart
class VideosApi {
  Future<List<Map<String, dynamic>>> fetchVideos() async {
    final res = await ApiClient.client.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final decoded = json.decode(res.body);
      return decoded.map<Map<String, dynamic>>((e) => { /* mapeo */ }).toList();
    }
  }
}
```

#### Mappers

Convierten los datos crudos de la API (JSON → `Map`) en entidades del dominio:

```dart
// data/mappers/video_mapper.dart
class VideoMapper {
  static Video fromJson(Map<String, dynamic> json) => Video(
    id: int.parse(json['id'].toString()),
    titol: json['titol'] ?? '',
    videoURL: json['videoURL'] ?? '',
    // ...
  );
}
```

#### Repository Implementations

Implementan los repositorios abstractos del dominio, delegando al datasource y mapeando con los mappers:

```dart
// data/repositories/videos_repository_impl.dart
class VideosRepositoryImpl implements VideosRepository {
  final VideosApi api;

  @override
  Future<List<Video>> getVideos() async {
    final models = await api.fetchVideos();
    return models.map((m) => VideoMapper.fromJson(m)).toList();
  }
}
```

---

### 3. Presentation (Presentación)

Contiene toda la interfaz de usuario: pantallas, widgets y providers de estado.

- **`login_screen.dart`** → Pantalla de login con petición a Odoo.
- **`home_screen.dart`** → Pantalla principal con carrusel de vídeos y navegación inferior.
- **`videos_screen.dart`** → Grid de vídeos filtrable por categoría.
- **`video_player_screen.dart`** → Reproductor de vídeo con controles y fullscreen.
- **`videoList_screen.dart`** → Lista de vídeos favoritos (wishlist) con Riverpod.
- **`provider/wishlist_notifier.dart`** → Estado global de la wishlist con Riverpod.

---

## ⚙️ Carpeta `config/`

### `api_config.dart`

Centraliza **todas las URLs** de las APIs. Detecta automáticamente la plataforma para usar la IP correcta:

- **Web** → `https://localhost:PUERTO`
- **Android** → `https://10.0.2.2:PUERTO` (IP especial del emulador Android para acceder al host)

```dart
class ApiConfig {
  static Map<String, String> get urls {
    if (kIsWeb) {
      return { "login": "https://localhost:8069/api/authenticate", ... };
    }
    if (Platform.isAndroid) {
      return { "login": "https://10.0.2.2:8069/api/authenticate", ... };
    }
    // fallback
    return { "login": "https://10.0.2.2:8069/api/authenticate", ... };
  }
}
```

**URLs definidas:**

| Clave | Servidor | Endpoint |
|-------|----------|----------|
| `login` | Odoo `:8069` | `/api/authenticate` |
| `refreshAccess` | Odoo `:8069` | `/api/update/access-token` |
| `rotateRefresh` | Odoo `:8069` | `/api/update/refresh-token` |
| `register` | Odoo `:8069` | `/web/signup` |
| `cataleg` | Spring Boot `:8081` | `/api/cataleg` |
| `catalegBySeries` | Spring Boot `:8081` | `/api/catalegBySerie/:id` |
| `catalegByName` | Spring Boot `:8081` | `/api/catalegByName/:name` |
| `series` | Spring Boot `:8081` | `/api/series` |
| `categorias` | Spring Boot `:8081` | `/api/categories` |
| `video` | Express `:3000` | `/api` |

### `api_client.dart` (config)

Cliente HTTP con **refresh automático del access token**. Antes de cada petición:

1. Verifica si el access token ha expirado (`isAccessExpired`).
2. Si está expirado, llama al endpoint `refreshAccess` de Odoo con el `refreshToken`.
3. Guarda el nuevo access token en la sesión.
4. Adjunta el header `Authorization: Bearer <token>` a la petición.

```dart
class ApiClient {
  Future<void> _refreshIfNeeded() async {
    final expired = await _session.isAccessExpired();
    if (!expired) return;
    // POST a Odoo /api/update/access-token con refreshToken en header
    // Guarda nuevo access_token en sesión
  }

  Future<http.Response> get(String url) async {
    final headers = await _authorizedHeaders(); // llama _refreshIfNeeded()
    return await http.get(Uri.parse(url), headers: headers);
  }
}
```

---

## 🔧 Carpeta `core/`

### `session_service.dart`

Gestiona la sesión del usuario utilizando **`FlutterSecureStorage`** para almacenar de forma segura:

- `access_token` — JWT de corta duración para autenticar peticiones.
- `refresh_token` — Token de larga duración para obtener nuevos access tokens.
- `user_id` — ID del usuario en Odoo.

**Métodos principales:**

| Método | Función |
|--------|---------|
| `saveSession()` | Guarda access token, refresh token y userId en storage seguro |
| `getAccessToken()` | Recupera el access token almacenado |
| `getRefreshToken()` | Recupera el refresh token almacenado |
| `getUserId()` | Recupera el userId almacenado |
| `clearSession()` | Elimina toda la sesión (logout) |
| `isAccessExpired()` | Decodifica el JWT con `JwtDecoder` y comprueba si ha expirado |
| `ensureValidAccessToken()` | Si el token está expirado, lo renueva automáticamente antes de devolverlo |
| `refreshAccessToken()` | Hace POST a Odoo `/api/update/refresh-token` para renovar tokens |
| `rotateRefreshToken()` | Rota el refresh token enviando POST a Odoo `/api/update/refresh-token` |

### `authenticated_http_client.dart`

Extiende `http.BaseClient` para interceptar **todas las peticiones HTTP** y manejar la autenticación de forma transparente:

1. **Antes de enviar**: llama a `ensureValidAccessToken()` y añade `Authorization: Bearer <token>` + `refresh-token` a los headers.
2. **Si recibe un 401**: intenta renovar el token (`_refreshTokenIfNeeded()`), copia la petición original con el nuevo token y la reintenta **una sola vez**.
3. **Evita renovaciones simultáneas**: usa un `Future<void>?` compartido para que múltiples peticiones no disparen múltiples refreshes a la vez.

```dart
class AuthenticatedHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _sessionService.ensureValidAccessToken();
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['refresh-token'] = refreshToken;

    var response = await _inner.send(request);

    if (response.statusCode == 401) {
      await _refreshTokenIfNeeded();
      // Reintenta con nuevo token
    }
    return response;
  }
}
```

### `api_client.dart` (core)

Proporciona un **singleton** de `http.Client` que:

1. Crea un `HttpClient` que **ignora errores de certificado SSL** (necesario para desarrollo con certificados autofirmados).
2. Lo envuelve en un `IOClient`.
3. Lo envuelve en `AuthenticatedHttpClient` para tener autenticación automática.

```dart
class ApiClient {
  static http.Client get client {
    final httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    final ioClient = IOClient(httpClient);
    _client = AuthenticatedHttpClient(innerClient: ioClient, ...);
    return _client!;
  }
}
```

### `service_locator.dart`

Implementa el patrón **Service Locator** como **singleton** para centralizar la creación e inyección de dependencias:

```
ServiceLocator (singleton)
├── VideosApi        →  VideosRepositoryImpl   →  GetVideos (use case)
├── SeriesApi        →  SeriesRepositoryImpl   →  GetSeries (use case)
└── CategoriasApi    →  CategoriasRepositoryImpl → GetCategorias (use case)
```

Se usa desde cualquier pantalla así:

```dart
final getVideos = ServiceLocator().getVideos;
final result = await getVideos(); // llama al use case → repository → api
```

---

## ❤️ Wishlist con Riverpod

La funcionalidad de **favoritos** se gestiona con **Riverpod** utilizando un `Notifier`:

### `wishlist_notifier.dart`

```dart
class WishlistNotifier extends Notifier<List<Video>> {
  @override
  List<Video> build() => []; // Estado inicial: lista vacía

  void add(Video video) {
    if (!state.any((v) => v.id == video.id)) {
      state = [...state, video]; // Inmutable: crea nueva lista
    }
  }

  void remove(Video video) {
    state = state.where((v) => v.id != video.id).toList();
  }

  bool contains(Video video) {
    return state.any((v) => v.id == video.id);
  }
}

// Provider global accesible desde cualquier widget
final wishlistProvider =
    NotifierProvider<WishlistNotifier, List<Video>>(WishlistNotifier.new);
```

### Uso en `videoList_screen.dart`

`VideolistScreen` es un `ConsumerWidget` (Riverpod) que:

1. **Lee** la lista de favoritos: `ref.watch(wishlistProvider)`
2. **Modifica** la lista: `ref.read(wishlistProvider.notifier).remove(video)`
3. Muestra cada vídeo favorito en una tarjeta con thumbnail y botón de eliminar.

```dart
class VideolistScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myWishList = ref.watch(wishlistProvider);         // Escucha cambios
    final wishlistNotifier = ref.read(wishlistProvider.notifier); // Para modificar

    return ListView.builder(
      itemCount: myWishList.length,
      itemBuilder: (context, index) {
        final video = myWishList[index];
        return _VideoWishlistCard(
          video: video,
          onDelete: () => wishlistNotifier.remove(video),
        );
      },
    );
  }
}
```

### `main.dart` — ProviderScope

Para que Riverpod funcione, la app se envuelve en un `ProviderScope`:

```dart
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

---

## 🔐 Login — Petición a Odoo

### Flujo completo

```
┌─────────────┐       POST /api/authenticate        ┌──────────┐
│ LoginScreen │  ──────────────────────────────────►  │   Odoo   │
│  (Flutter)  │  body: {login, password, db}         │  :8069   │
│             │  ◄──────────────────────────────────  │          │
│             │  response: {token, refreshToken}     └──────────┘
└─────────────┘
       │
       ▼
  SessionService.saveSession()
  → FlutterSecureStorage:
    • access_token
    • refresh_token
    • user_id (extraído del JWT)
       │
       ▼
  SessionService.rotateRefreshToken()
  → POST /api/update/refresh-token
       │
       ▼
  Navigator → HomeScreen
```

### Código del login

```dart
Future<void> _login(String email, String password) async {
  final params = {
    "params": {"login": email, "password": password, "db": "Justflix"}
  };

  // Cliente HTTP que ignora certificados SSL autofirmados
  final ioc = HttpClient();
  ioc.badCertificateCallback = (cert, host, port) => true;
  final client = IOClient(ioc);

  final response = await client.post(
    Uri.parse(ApiConfig.urls["login"]!),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    },
    body: jsonEncode(params),
  );

  final data = jsonDecode(response.body);
  final result = data['result'] ?? data;

  // Extraer tokens
  final String accessToken = result['token'];
  final String refreshToken = result['refreshToken'];
  final decodedToken = JwtDecoder.decode(accessToken);
  final userId = decodedToken['user_id'];

  // Guardar en almacenamiento seguro
  final sessionService = SessionService(const FlutterSecureStorage());
  await sessionService.saveSession(
    accessToken: accessToken,
    refreshToken: refreshToken,
    userId: userId,
  );

  // Rotar el refresh token tras el primer login
  await sessionService.rotateRefreshToken();

  // Navegar al Home
  Navigator.pushReplacement(context,
    MaterialPageRoute(builder: (_) => const HomeScreen()),
  );
}
```

### ¿Para qué se usan los tokens?

| Token | Almacenamiento | Vida útil | Uso |
|-------|---------------|-----------|-----|
| **Access Token** | `FlutterSecureStorage` | Corta (minutos) | Se envía como `Authorization: Bearer <token>` en cada petición autenticada |
| **Refresh Token** | `FlutterSecureStorage` | Larga (horas/días) | Se usa para obtener un nuevo access token cuando este expira, sin volver a pedir credenciales |
| **User ID** | `FlutterSecureStorage` | Sesión | Se extrae del JWT y se usa para identificar al usuario en las peticiones de refresh |

---

## 📺 Petición a Spring Boot — Listado de vídeos

La petición para obtener los vídeos del catálogo se hace al servidor **Spring Boot** (puerto `8081`):

### Flujo

```
ServiceLocator.getVideos
    └── GetVideos.call()
        └── VideosRepositoryImpl.getVideos()
            └── VideosApi.fetchVideos()
                └── ApiClient.client.get("https://10.0.2.2:8081/api/cataleg")
                    └── AuthenticatedHttpClient.send()
                        → Añade Authorization: Bearer <token>
                        → Añade refresh-token header
                        → GET https://10.0.2.2:8081/api/cataleg
```

### Código del datasource

```dart
// data/datasources/videos_api.dart
Future<List<Map<String, dynamic>>> fetchVideos() async {
  final res = await ApiClient.client.get(Uri.parse(baseUrl));
  // baseUrl = "https://10.0.2.2:8081/api/cataleg"

  if (res.statusCode == 200) {
    final decoded = json.decode(res.body); // List<dynamic>
    return decoded.map<Map<String, dynamic>>((e) => {
      'id': e['id'],
      'titol': e['titol'],
      'videoURL': e['videoURL'],
      'thumbnailURL': e['thumbnailURL'],
      'descripcio': e['descripcio'],
      'duracio': e['duracio'],
      'serie': e['serie'],
      'edat': e['edat'],
      'nivell': e['nivell'],
      'categories': List<int>.from(e['categories']),
    }).toList();
  }
}
```

La respuesta JSON se mapea con `VideoMapper.fromJson()` para convertirla en entidades `Video` del dominio.

**Endpoints disponibles en Spring Boot:**

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/cataleg` | Todos los vídeos |
| GET | `/api/catalegBySerie/:id` | Vídeos de una serie concreta |
| GET | `/api/catalegByName/:name` | Buscar vídeos por nombre |
| GET | `/api/series` | Todas las series |
| GET | `/api/seriesByName/:name` | Buscar series por nombre |
| GET | `/api/categories` | Todas las categorías |

---

## 🎬 Petición a Express — Reproducción de vídeo

La reproducción de vídeo se hace contra el servidor **Express** (puerto `3000`). La URL del vídeo se construye concatenando la base URL de Express con la `videoURL` del vídeo.

### Flujo

```
VideoPlayerScreen
    │
    ├── 1. HEAD request (obtener nuevos tokens si los hay)
    │   → HEAD https://10.0.2.2:3000/api/videos/mi_video.mp4
    │   → Headers: Authorization + refresh-token
    │   → Si responde con x-new-token / x-new-refresh-token → guardarlos
    │
    └── 2. Inicializar VideoPlayerController
        → VideoPlayerController.networkUrl(
            "https://10.0.2.2:3000/api/videos/mi_video.mp4",
            httpHeaders: {
              'Authorization': 'Bearer <token>',
              'refresh-token': '<refreshToken>',
            },
          )
```

### Código de inicialización del vídeo

```dart
Future<void> _initializeVideo() async {
  final String baseUrl = ServiceLocator().getVideoUrl();  // https://10.0.2.2:3000/api
  final sessionService = SessionService(const FlutterSecureStorage());
  String? token = await sessionService.ensureValidAccessToken();
  String? refreshToken = await sessionService.getRefreshToken();

  // 1. Petición HEAD para comprobar tokens
  final uri = Uri.parse("$baseUrl${widget.video.videoURL}");
  final client = HttpClient();
  final request = await client.openUrl('HEAD', uri);
  request.headers.set('Authorization', 'Bearer $token');
  request.headers.set('refresh-token', refreshToken);
  final response = await request.close();

  // Si el servidor devuelve tokens nuevos, guardarlos
  final newToken = response.headers.value('x-new-token');
  final newRefreshToken = response.headers.value('x-new-refresh-token');
  if (newToken != null) {
    await sessionService.saveSession(accessToken: newToken, ...);
    token = newToken;
  }

  // 2. Crear el reproductor de vídeo
  _videoController = VideoPlayerController.networkUrl(
    Uri.parse("$baseUrl${widget.video.videoURL}"),
    httpHeaders: {
      'Authorization': 'Bearer $token',
      'refresh-token': refreshToken,
    },
  );

  await _videoController!.initialize();
  await _videoController!.play();
}
```

### ¿Por qué una petición HEAD primero?

El `VideoPlayerController` de Flutter no permite interceptar respuestas para actualizar tokens. Por eso, **antes de iniciar el streaming**, se hace una petición `HEAD` para:

1. Verificar que los tokens son válidos.
2. Recibir tokens renovados en los headers de respuesta (`x-new-token`, `x-new-refresh-token`).
3. Usar los tokens actualizados al crear el `VideoPlayerController`.

---

## 🔄 `main.dart` — Punto de entrada

```dart
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides(); // Ignora certificados SSL globalmente
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(    // Habilita Riverpod en toda la app
      child: MyApp(),
    ),
  );
}
```

- **`MyHttpOverrides`**: Acepta certificados SSL autofirmados para desarrollo local.
- **`ProviderScope`**: Envuelve la app para que los providers de Riverpod (como `wishlistProvider`) funcionen globalmente.
- **`LoginScreen`**: Es la pantalla inicial; tras un login exitoso, navega a `HomeScreen`.

---

## 📦 Dependencias principales

| Paquete | Uso |
|---------|-----|
| `http` | Peticiones HTTP |
| `flutter_secure_storage` | Almacenamiento seguro de tokens |
| `jwt_decoder` | Decodificar y verificar expiración de JWT |
| `flutter_riverpod` | Gestión de estado (wishlist) |
| `video_player` | Reproducción de vídeo |
| `url_launcher` | Abrir URLs externas (registro) |
