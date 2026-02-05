import { createRouter, createWebHistory } from "vue-router";
import LoginView from "../views/LoginView.vue";
import AdminView from "../views/AdminView.vue";
import ListaView from "../views/ListaView.vue";
import ConfigView from "../views/ConfigView.vue";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/",
      name: "login",
      component: LoginView,
    },
    {
      path: "/admin",
      name: "admin",
      component: AdminView,
    },
    {
      path: "/lista",
      name: "lista",
      component: ListaView,
    },
    {
      path: "/config",
      name: "config",
      component: ConfigView,
    },
  ],
});

export default router;
