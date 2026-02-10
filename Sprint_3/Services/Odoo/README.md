# 📖 Guía de Odoo (Para Torpes... pero Jefes)

Bienvenido a la documentación de **Odoo**. Aquí te explico cómo funciona este "bicho" sin tecnicismos raros, para que puedas meter mano sin romper nada (o al menos saber qué has roto).

---

## 🏗️ Arquitectura (¿Cómo está montado esto?)

Imagina que Odoo es una casa.
- **El contenedor `odoo`**: Es la casa en sí, donde vive la aplicación.
- **La base de datos `db` (PostgreSQL)**: Es el sótano donde se guardan todos los datos (clientes, ventas, etc.). Sin esto, Odoo no recuerda nada.
- **Nginx**: Es el portero de la finca. Nadie entra directo a la casa (puerto 8069); todos pasan primero por el portero (puerto 443/80) que les abre la puerta.

El **`docker-compose.yml`** es el plano de arquitecto que dice cómo se conecta todo esto.

---

## 📂 Carpetas Importantes (¡No toques las otras!)

Aquí es donde está la "chicha". Todo lo que necesitas tocar está mapeado (conectado) desde tu ordenador al contenedor.

### 1. `config/` (La configuración)
Aquí vive el archivo **`odoo.conf`**.
- **¿Qué es?**: El cerebro de la configuración.
- **¿Para qué sirve?**: Aquí se define la contraseña maestra (`admin_passwd`), los puertos y las rutas de los addons.
- **⚠️ Cuidado**: Si cambias algo aquí, necesitas reiniciar el contenedor para que Odoo se entere de los cambios.

### 2. `extra-addons/` (Tus Módulos Personalizados)
Aquí es donde metemos nuestros "superpoderes" (código propio).
- **Módulos actuales**:
  - `odoo_jwt`: Se encarga de la autenticación segura (tokens JWT) para que la API sea robusta.
  - `subscription_timer`: Gestiona la lógica de las suscripciones (tiempos, renovaciones, etc.).
- **¿Cómo añadir uno nuevo?**:
  1. Crea una carpeta aquí con tu módulo.
  2. Reinicia Odoo.
  3. Ve a "Aplicaciones" en Odoo, dale a "Actualizar lista de aplicaciones" y búscalo.

### 3. `log/` (El Chivato)
Aquí se guardan los archivos de registro.
- **¿Algo no funciona?**: Mira aquí primero. Odoo escribe aquí cada vez que le duele algo.

### 4. `filestore/` (El Trastero)
Aquí Odoo guarda archivos adjuntos, imágenes de productos, facturas en PDF, etc. No deberías necesitar tocar esto manualmente.

---

## 🛠️ Cómo Modificar Cosas

### Quiero cambiar la configuración de Odoo
1. Ve a la carpeta `config`.
2. Abre `odoo.conf` con cualquier editor de texto.
3. Haz tus cambios.
4. Reinicia el contenedor (ver abajo "Comandos Útiles").

### Quiero arreglar o cambiar código de un módulo (ej. `odoo_jwt`)

1. **Autenticación (Login/Registro)**:
   - Archivo: `extra-addons/odoo_jwt/controllers/api_uth.py`
   - Aquí está la lógica de `login`, `signup` y validación de tokens.

2. **Suscripciones**:
   - Archivo: `extra-addons/subscription_timer/models/subscription.py`
   - Aquí se define qué es una suscripción y cuánto dura.

3. **Pasos para aplicar cambios**:
   - Modifica el archivo `.py`.
   - **Reinicia el contenedor** (`docker restart ...`).
   - Si añades campos nuevos a la base de datos, ve a Apps y dale a **Actualizar** en el módulo.

---

## 🚀 Comandos Útiles (Copia y Pega)

Ejecuta esto desde la carpeta donde está el `docker-compose.yml` (la raíz del proyecto):

- **Reiniciar Odoo** (obligatorio tras cambiar código Python):
  ```bash
  docker restart odoo-service
  ```
  *(Nota: revisa el nombre exacto del contenedor con `docker ps`, suele ser algo como `sprint_3-odoo-1` o similar)*.

- **Ver logs en tiempo real** (para ver si explota):
  ```bash
  docker logs -f odoo-service
  ```

---

## ✨ Funcionalidades Especiales (La Magia)

Este Odoo no es uno del montón. Tiene **esteroides**:

1.  **JWT Authentication (`odoo_jwt`)**:
    *   Este módulo permite que otras Apps (como la de Flutter o React) se conecten a Odoo de forma segura usando "tokens".
    *   Si la App móvil no conecta, revisa que este módulo esté instalado y configurado.

2.  **Gestión de Suscripciones (`subscription_timer`)**:
    *   Controla la vigencia de las suscripciones de los usuarios.
    *   Si las suscripciones no expiran o no se renuevan, el problema está en el código de este módulo.

---
*Hecho por tu asistente de IA favorito. ¡A picar código!* 🤖
