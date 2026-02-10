# 📱 JustFlix App Móvil - Guía para "Tontos" (o gente con prisa)

¡Hola! 👋 Si estás leyendo esto es porque te toca meterle mano a la App Móvil y no sabes por dónde empezar. Tranquilo, aquí te explico **qué es cada cosa** para que puedas cambiar lo que necesites sin romper nada (esperemos).

## 📂 ¿Dónde está lo importante?

Todo el código que te interesa está dentro de la carpeta `lib`. Olvídate del resto por ahora. Dentro de `lib`, la estructura es la siguiente:

### 1. **`lib/features`** (Aquí está "la chicha")
Esta es la carpeta principal. Dentro verás varias carpetas raras (`data`, `domain`, `presentation`), pero **solo te importa una si quieres cambiar lo que se ve en pantalla**:

- **`presentation`**: **¡AQUÍ ESTÁ LO VISUAL!** 🎨
  - Si quieres cambiar algo de la **Pantalla de Inicio**, ve a `presentation/menu/home_screen.dart`.
  - Si quieres tocar el **Login**, ve a `presentation/login_screen.dart`.
  - Si quieres modificar el **Perfil**, ve a `presentation/perfil`.
  - Si quieres cambiar cómo se muestran los **Videos**, ve a `presentation/videoList`.

### 2. **`lib/config`**
Aquí están las configuraciones globales, como rutas o temas de colores. Si cambias algo aquí, afecta a toda la app.

### 3. **`lib/features/domain/entities`**
Aquí se define **CÓMO SON LOS DATOS**.
- Por ejemplo, si quieres saber qué información guardamos de un "Video" (titulo, url, etc.), mira el archivo `video.dart`.

---

## 🛠️ ¿Cómo cambio cosas?

### "Quiero cambiar un texto o un color de un botón"
1. Ve a `lib/features/presentation`.
2. Busca la carpeta de la pantalla que quieres cambiar (ej. `login` o `menu`).
3. Abre el archivo `.dart` y busca el texto que quieres cambiar.
4. Guarda y recarga la app.

### "Quiero añadir un campo nuevo a los Videos"
1. Ve a `lib/features/domain/entities/video.dart` y añádelo ahí.
2. Luego tendrás que ir a `lib/features/data` para asegurarte de que la app sepa leer ese nuevo dato desde internet (pero eso ya es nivel avanzado 😉).

---

## 🚀 Cómo arrancar esto
Si tienes Flutter instalado, solo abre una terminal en esta carpeta y escribe:

```bash
flutter run
```

¡Y listo! A picar código. 💻🔥
