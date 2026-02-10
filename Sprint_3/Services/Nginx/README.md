# 🛡️ Guía de Nginx (El Portero de Discoteca)

Bienvenido a la documentación de **Nginx**. Si Odoo es la casa, Nginx es el **portero de discoteca** que decide quién entra y a dónde va.

---

## 🏗️ Arquitectura (¿Qué hace este señor?)

Nginx es un **Proxy Inverso**. Suena complicado, pero es simple:
1.  **Recibe Tráfico**: "Oye, quiero ver la web".
2.  **Filtra**: Mira si tienes permiso (certificado SSL, puerto correcto).
3.  **Redirige**: "Pasa, ve a la mesa 4 (Odoo)".
    *   Tú entras por el puerto 80 (web normal) o 443 (web segura).
    *   Y Nginx le chiva la petición a Odoo en el puerto interno 8069.
    *   **¡Magia!**: Nadie ve el 8069, solo ven el 443. Es más seguro.

---

## 📂 Carpetas Importantes (Donde está el truco)

Todo lo que necesitas tocar está mapeado (conectado) desde tu ordenador al contenedor.

### 1. `conf.d/` (Las Reglas del Juego)
Aquí vive el archivo **`default.conf`**.
- **¿Qué es?**: El manual de instrucciones del portero.
- **¿Para qué sirve?**: Dice "si alguien viene a `midominio.com`, mándalo a Odoo". También configura cosas de seguridad (SSL).
- **⚠️ Cuidado**: Si la lías aquí, nadie entra. Nginx da error y se cierra.

### 2. `certs/` (Los Pasaportes)
Aquí se guardan los certificados SSL (el candadito verde 🔒).
- **Archivos típicos**: `.crt` (certificado público) y `.key` (llave privada).
- **Nota**: Si esos archivos faltan o caducan, el navegador gritará "SITIO NO SEGURO".

---

## 🛠️ Cómo Modificar la Configuración

### Quiero añadir una redirección o cambiar puertos
1. Ve a la carpeta `conf.d`.
2. Edita `default.conf`.
3. Busca bloques que empiecen por `server { ... }`.
4. **Guarda y recarga** (ver abajo "Comandos Útiles").

### Ejemplo rápido de configuración (`default.conf`)
Para que lo entiendas sin ser ingeniero de la NASA:
```nginx
server {
    listen 80;  # Escucha en el puerto 80
    server_name midominio.com;

    location / {
        proxy_pass http://odoo:8069; # Manda todo a Odoo
        # ... más cosas técnicas de cabeceras ...
    }
}
```

---

## 🚀 Comandos Útiles (Copia y Pega)

Ejecuta esto desde la carpeta raíz del proyecto:

- **Recargar Nginx** (SIN tirar el servidor, ideal para cambios de config):
  ```bash
  docker exec nginx-service nginx -s reload
  ```
  *(Nota: cambia `nginx-service` por el nombre real de tu contenedor si es diferente, usa `docker ps` para verlo).*

- **Reiniciar todo** (si la lías mucho):
  ```bash
  docker restart nginx-service
  ```

- **Ver logs de acceso** (quién entra):
  ```bash
  docker logs -f nginx-service
  ```

---
*Hecho por tu asistente de IA favorito. ¡A configurar!* 🤖
