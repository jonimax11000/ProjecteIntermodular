<template>
  <div class="app-layout">
    <SidebarMenu v-if="showSidebar" />

    <main class="main-content" :class="{ 'with-sidebar': showSidebar }">
      <router-view />
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import SidebarMenu from '@/components/common/SidebarMenu.vue';

const route = useRoute();

// Ocultamos el sidebar en la página de Login (ruta '/')
const showSidebar = computed(() => {
  return route.path !== '/';
});
</script>

<style>
/* Reset global básico */
html,
body {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  background-color: #f0f2f5;
}

* {
  box-sizing: border-box;
}

.app-layout {
  display: flex;
  min-height: 100vh;
}

.main-content {
  flex-grow: 1;
  width: 100%;
  transition: margin-left 0.3s;
}

/* Cuando el sidebar existe, empujamos el contenido 260px a la derecha */
.main-content.with-sidebar {
  margin-left: 260px;
}
</style>