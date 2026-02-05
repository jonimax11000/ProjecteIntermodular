import { fileURLToPath, URL } from "node:url";
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),
    },
  },
  server: {
    proxy: {
      "/odoo-api": {
        target: "https://localhost:8069",
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/odoo-api/, ""),
        configure: (proxy, options) => {
          proxy.on("proxyReq", (proxyReq, req, res) => {
            proxyReq.removeHeader("cookie");
            proxyReq.setHeader("User-Agent", "PostmanRuntime/7.32.3");
          });
        },
      },
      "/node-api": {
        target: "https://localhost:3000/api",
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/node-api/, ""),
      },
      "/api": {
        target: "https://localhost:8081",
        changeOrigin: true,
        secure: false,
      },
    },
  },
});
