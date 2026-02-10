# Admin Web - Justflix 🎬

¡Bienvenido al panel de administración de Justflix! 👋

Este proyecto es la **parte visual (Frontend)** que utilizan los administradores para gestionar el contenido de la plataforma (subir videos, crear series, gestionar categorías, etc.). Está construido con una tecnología llamada **Vue.js**, que facilita la creación de páginas web interactivas.

Si eres nuevo en programación, ¡no te preocupes! Esta guía te explicará todo paso a paso para que entiendas cómo funciona y cómo modificarlo.

---

## 🏗️ Arquitectura: ¿Cómo funciona esto?

Imagina que este programa es como un restaurante:

1.  **El Cliente (Frontend)**: Es esta web (`admin-web`). Es la carta y los camareros. Es lo que tú ves y tocas en el navegador.
2.  **La Cocina (Backend)**: Aquí es donde ocurre la magia "real" (guardar datos, procesar archivos). Este frontend habla con **TRES cocinas diferentes**:
    *   **Java (Spring Boot)** ☕: Es la base de datos principal. Guarda la información de texto: títulos de películas, categorías, series, edades recomendadas, etc.
    *   **Node.js** 🟢: Es el almacén de archivos. Se encarga de guardar los videos `.mp4` y las imágenes `.jpg` que subes.
    *   **Odoo** 🟣: Es el portero. Se encarga de comprobar tu usuario y contraseña (Login) para dejarte entrar.

El frontend (esta web) usa "pedidos" (llamadas API) para pedir o enviar datos a estas tres cocinas.

---

## 🛠️ Tecnologías utilizadas

*   **Vue.js (versión 3)**: El "framework" (marco de trabajo) principal. Nos ayuda a construir la web usando "componentes" (piezas de Lego) en lugar de escribir todo desde cero.
*   **Vite**: Es la herramienta que hace funcionar el servidor de desarrollo. Es muy rápida y se encarga de traducir nuestro código para que el navegador lo entienda.
*   **Axios**: Es el cartero 📬. Es una librería que usamos para enviar los datos (pedidos) a las "cocinas" (Backends) y recibir las respuestas.
*   **Vue Router**: Es el GPS 🗺️. Se encarga de cambiar de página (por ejemplo, de "Login" a "Admin") sin recargar toda la web.

---

## 📂 Estructura del Proyecto: ¿Dónde está cada cosa?

Aquí tienes un mapa de las carpetas más importantes para que no te pierdas:

*   **`public/`**: Archivos que se sirven tal cual (imágenes estáticas, iconos).
*   **`src/`**: ¡Aquí está todo el código fuente! 🧠
    *   **`components/`**: Piezas reutilizables de la web. Si tienes un botón o un formulario que usas en muchas páginas, debería estar aquí.
    *   **`router/`**: Aquí vive el archivo `index.js`. Es donde definimos las **rutas** (URLs). Por ejemplo: "Si la URL es `/admin`, muestra la página `AdminView.vue`".
    *   **`services/`**: Aquí está `api.js`. Este archivo es MUY IMPORTANTE. Contiene todas las funciones para hablar con el Backend (Login, subir video, pedir lista de series, etc.). Si algo falla al guardar o cargar datos, mira aquí.
    *   **`views/`**: Son las **Páginas** completas de la web.
        *   `LoginView.vue`: La pantalla de inicio de sesión.
        *   `AdminView.vue`: La pantalla principal de administración.
        *   `ListaView.vue`: Una lista de contenidos.
        *   `ConfigView.vue`: Pantalla de configuración.
    *   **`App.vue`**: Es el componente "padre" de todos. Todo lo que pongas aquí saldrá en TODAS las páginas.
    *   **`main.js`**: El punto de entrada. Aquí arranca la aplicación Vue.
*   **`vite.config.js`**: El archivo de configuración de Vite. Aquí es donde configuramos los "Proxies" para conectar con los Backends sin problemas de seguridad (CORS).

---

## 🚀 Cómo arrancar el proyecto

Necesitas tener instalado **Node.js** en tu ordenador.

1.  **Instalar las dependencias** (solo la primera vez):
    Abre una terminal en esta carpeta y escribe:
    ```bash
    npm install
    ```
    Esto descargará todas las librerías necesarias (Vue, Axios, etc.) en la carpeta `node_modules`.

2.  **Arrancar el servidor de desarrollo**:
    Para ver la web y trabajar en ella, escribe:
    ```bash
    npm run dev
    ```
    La terminal te mostrará una dirección (normalmente `http://localhost:5173/`). Abre eso en tu navegador web.

---

## ✏️ Guía para Modificar el Código

### 1. Quiero cambiar el texto o el diseño de una página
Ve a la carpeta `src/views/`. Abre el archivo de la página que quieres cambiar (por ejemplo, `AdminView.vue`).
Los archivos `.vue` tienen 3 partes:
*   `<template>`: El **HTML**. La estructura visual (botones, textos, inputs).
*   `<script>`: La **Lógica**. El código JavaScript que hace que los botones funcionen.
*   `<style>`: El **CSS**. Los colores, tamaños y márgenes.

### 2. Quiero añadir una nueva página
1.  Crea un nuevo archivo en `src/views/` (ej: `NuevaPagina.vue`).
2.  Ve a `src/router/index.js`.
3.  Importa tu nueva página arriba del todo.
4.  Añade un nuevo objeto a la lista `routes`:
    ```javascript
    {
      path: '/nueva-pagina',
      name: 'nueva',
      component: NuevaPagina
    }
    ```
5.  ¡Listo! Ahora puedes ir a `http://localhost:5173/nueva-pagina`.

### 3. Quiero arreglar o añadir una llamada al servidor
Ve a `src/services/api.js`.
Ahí verás funciones como `login`, `saveVideoJava`, `uploadVideoNode`.
*   Si es un problema de datos (títulos, series), mira las funciones que usan `JAVA_API`.
*   Si es un problema de archivos (subir video), mira las que usan `NODE_API`.
*   Si es el login, mira `ODOO_API`.

Puedes añadir nuevas funciones siguiendo el ejemplo de las existentes:
```javascript
async miNuevaFuncion(dato) {
  return await JAVA_API.get("/mi-nuevo-endpoint");
}
```

### 4. La web no conecta con el servidor
Revisa el archivo `vite.config.js`. Ahí están definidos los "proxies".
Asegúrate de que los servidores Backend estén encendidos y corriendo en los puertos correctos:
*   Java: puerto 8081
*   Node: puerto 3000
*   Odoo: puerto 8069

---

¡Buena suerte programando! 👨‍💻👩‍💻
