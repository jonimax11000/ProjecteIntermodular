import axios from "axios";
import { ref } from "vue";

// --- 1. CONFIGURACIÓN JAVA (Spring Boot) ---
const JAVA_API = axios.create({
  // 👇 IMPORTANTE: Usamos '/api' para pasar por el Proxy de Vite
  // (Si pones https://localhost:8081 directo, dará error de certificado)
  baseURL: "/api",
  headers: { "Content-Type": "application/json" },
});

// INTERCEPTOR: Inyecta el Token en cada petición a Java
JAVA_API.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("jwt_token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  },
);

// --- 2. CONFIGURACIÓN ODOO ---
const ODOO_API = axios.create({
  baseURL: "/odoo-api",
  headers: {
    "Content-Type": "application/json",
    Accept: "*/*",
  },
  withCredentials: false,
});

// --- 3. CONFIGURACIÓN NODE (Express / Archivos) ---
const NODE_API = axios.create({
  baseURL: "/node-api",
  headers: { "Content-Type": "multipart/form-data" },
});

NODE_API.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("jwt_token"); // Asegúrate que el nombre es correcto
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error),
);

export default {
  // --- LOGIN (Odoo) ---
  async login(email, password) {
    const payload = {
      jsonrpc: "2.0",
      method: "call",
      id: Math.floor(Math.random() * 1000),
      params: {
        login: email,
        password: password,
        db: "Justflix",
      },
    };

    console.log("Enviado a odoo 🥳", payload);

    const res = await ODOO_API.post("/api/authenticate", payload);

    if (res.data.error) {
      throw new Error(
        res.data.error.data?.message ||
        res.data.error.message ||
        "Error en Odoo",
      );
    }

    console.log(res.data);

    return res.data.result;
  },

  // --- JAVA (Base de Datos) ---

  async getListas() {
    // Carga todas las listas necesarias para el formulario
    const [edats, nivells, series, cats] = await Promise.all([
      JAVA_API.get("/edats"),
      JAVA_API.get("/nivells"),
      JAVA_API.get("/series"),
      JAVA_API.get("/categories"),
    ]);
    return {
      edats: edats.data,
      nivells: nivells.data,
      series: series.data,
      categorias: cats.data,
    };
  },

  async getCatalogo() {
    const res = await JAVA_API.get("/cataleg");
    return res.data;
  },

  async getVideo(id) {
    const res = await JAVA_API.get("/cataleg");
    return res.data.find((v) => v.id == id);
  },

  async saveVideoJava(payload) {
    return await JAVA_API.post("/cataleg", payload);
  },

  async deleteVideoJava(id) {
    return await JAVA_API.delete(`/cataleg/${id}`);
  },

  // --- BORRADO DE ENTIDADES (Java) ---
  async deleteCategoria(id) {
    return await JAVA_API.delete(`/categories/${id}`);
  },
  async deleteSerie(id) {
    return await JAVA_API.delete(`/series/${id}`);
  },
  async deleteEdat(id) {
    return await JAVA_API.delete(`/edats/${id}`);
  },
  async deleteNivell(id) {
    return await JAVA_API.delete(`/nivells/${id}`);
  },

  // --- NODE (Archivos MP4/JPG) ---

  async uploadVideoNode(file, forcedName, nivel, clientId) {
    const fd = new FormData();
    fd.append("video", file, forcedName);
    fd.append("nivel", nivel);

    const config = {
      headers: {
        "X-Client-ID": clientId || "unknown-client",
      },
    };

    const res = await NODE_API.post("/video", fd, config);

    return res.data;
  },

  async deleteFileNode(videoName, thumbName) {
    return await NODE_API.delete("/video", {
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${localStorage.getItem("jwt_token")}`,
      },
      data: { video: videoName, thumbnail: thumbName },
    });
  },

  // Helper para ver las imágenes
  getThumbnailUrl(filename, nivel) {
    if (!filename || filename === "pendiente.jpg") {
      return "https://via.placeholder.com/300x169?text=Sin+Imagen";
    }

    if (filename.startsWith("http")) {
      return filename;
    }

    // Usamos el proxy '/node-api' en lugar de 'https://localhost:3000/api'
    // para evitar el error ERR_CERT_AUTHORITY_INVALID (el proxy tiene secure: false)
    if (filename.startsWith("/")) {
      return `/node-api${filename}`;
    }

    const nivelId = nivel || 0;
    return `/node-api/thumbnails/${nivelId}/${filename}`;
  },

  // --- CREACIÓN DE ENTIDADES (Java) ---

  async createSerie(nom, temporada) {
    const payload = {
      id: null,
      nom: nom,
      temporada: parseInt(temporada),
      descripcio: "",
    };
    const res = await JAVA_API.post("/series", payload);
    return res.data;
  },

  async createEdat(edat) {
    const payload = {
      id: null,
      edat: parseInt(edat),
      descripcio: "A partir de " + edat + " años",
    };
    const res = await JAVA_API.post("/edats", payload);
    return res.data;
  },

  async createNivell(nivell) {
    const payload = {
      id: null,
      nivell: nivell,
      nom: nivell,
    };
    const res = await JAVA_API.post("/nivells", payload);
    return res.data;
  },

  async createCategoria(nombre) {
    const payload = {
      id: null,
      categoria: nombre,
    };
    const res = await JAVA_API.post("/categories", payload);
    return res.data;
  },

  async refreshToken() {
    try {
      const payload = {
        jsonrpc: "2.0",
        method: "call",
        id: Math.floor(Math.random() * 1000),
        params: {
          login: email,
          password: password,
          db: "Justflix",
        },
      };

      const config = {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${localStorage.getItem("jwt_token")}`,
          refreshToken: localStorage.getItem("refresh_token"),
        },
      };
      const res = await ODOO_API.post("/api/update/access-token");
      const newToken = res.data.token;
      localStorage.setItem("jwt_token", newToken);
      return newToken;
    }
    catch (error) {
      console.error("Error al refrescar token:", error);
      throw error;
    }
  },
};


