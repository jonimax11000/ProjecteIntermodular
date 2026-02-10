<template>
    <aside class="sidebar">
        <div class="sidebar-header">
            <span class="logo-icon">🎬</span>
            <h2>JustFlix Admin</h2>
        </div>

        <nav class="sidebar-nav">
            <router-link to="/lista" class="nav-item" active-class="active">
                <span class="icon">📋</span>
                Catálogo
            </router-link>

            <router-link to="/admin" class="nav-item" active-class="active">
                <span class="icon">⬆️</span>
                Subir Vídeo
            </router-link>

            <router-link to="/config" class="nav-item" active-class="active">
                <span class="icon">⚙️</span>
                Configuración
            </router-link>
        </nav>

        <div class="sidebar-footer">
            <button @click="logout" class="btn-logout">
                <span class="icon">🚪</span> Cerrar Sesión
            </button>
        </div>
    </aside>
</template>

<script setup>
import { useRouter } from 'vue-router';

const router = useRouter();

const logout = () => {
    if (confirm("¿Seguro que quieres cerrar sesión?")) {
        localStorage.removeItem('jwt_token');
        router.push('/');
    }
};
</script>

<style scoped>
.sidebar {
    width: 260px;
    background-color: #1f2937;
    /* Gris muy oscuro/azulado */
    color: #f3f4f6;
    height: 100vh;
    position: fixed;
    left: 0;
    top: 0;
    display: flex;
    flex-direction: column;
    border-right: 1px solid #111827;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    z-index: 1000;
}

.sidebar-header {
    padding: 25px 20px;
    display: flex;
    align-items: center;
    gap: 12px;
    background-color: #111827;
    /* Aún más oscuro para la cabecera */
    border-bottom: 1px solid #374151;
}

.logo-icon {
    font-size: 1.8rem;
}

.sidebar-header h2 {
    font-size: 1.2rem;
    margin: 0;
    font-weight: bold;
    letter-spacing: 0.5px;
}

.sidebar-nav {
    flex-grow: 1;
    padding: 20px 0;
    display: flex;
    flex-direction: column;
    gap: 5px;
}

.nav-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 15px 25px;
    color: #9ca3af;
    text-decoration: none;
    font-weight: 500;
    font-size: 1rem;
    transition: all 0.2s ease;
    border-left: 4px solid transparent;
}

.nav-item:hover {
    background-color: #374151;
    color: #ffffff;
}

/* Estado Activo: Se ilumina en rojo cuando estás en esa página */
.nav-item.active {
    background-color: #E50914;
    /* Rojo Justflix */
    color: #ffffff;
    border-left: 4px solid #ffffff;
    /* Barrita blanca a la izquierda */
    font-weight: bold;
}

.sidebar-footer {
    padding: 20px;
    border-top: 1px solid #374151;
}

.btn-logout {
    width: 100%;
    padding: 12px;
    background-color: transparent;
    color: #9ca3af;
    border: 1px solid #4b5563;
    border-radius: 6px;
    cursor: pointer;
    font-weight: bold;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    transition: background-color 0.2s;
}

.btn-logout:hover {
    background-color: #374151;
    color: #ffffff;
}
</style>