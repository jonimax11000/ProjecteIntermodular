<template>
    <div class="config-container">
        <main class="main-content">
            <div class="header-section">
                <div class="header-text">
                    <h1>⚙️ Gestión del Catálogo</h1>
                    <p class="subtitle">Crea, edita y elimina los metadatos de tu plataforma.</p>
                </div>
            </div>

            <div v-if="loading" class="loading-state">
                <p>Cargando datos del servidor...</p>
            </div>

            <div v-else class="grid-dashboard">

                <section class="config-card">
                    <div class="card-header">
                        <h2>Categorías</h2>
                        <span class="count-badge">{{ listas.categorias.length }}</span>
                    </div>
                    <form @submit.prevent="crearCategoria" class="add-form">
                        <input v-model="nuevaCategoria" placeholder="Ej: Terror" required />
                        <button type="submit" class="btn-add" :disabled="isSaving">➕</button>
                    </form>
                    <ul class="item-list">
                        <li v-for="cat in listas.categorias" :key="cat.id" class="list-item">
                            <span class="item-name">{{ cat.categoria || cat.nom }}</span>
                            <button class="btn-delete" @click="borrarCategoria(cat)" title="Borrar">🗑️</button>
                        </li>
                    </ul>
                </section>

                <section class="config-card">
                    <div class="card-header">
                        <h2>Series</h2>
                        <span class="count-badge">{{ listas.series.length }}</span>
                    </div>
                    <form @submit.prevent="crearSerie" class="add-form double">
                        <input v-model="nuevaSerie.nom" placeholder="Nombre" required />
                        <input v-model="nuevaSerie.temp" type="number" min="1" placeholder="T." required />
                        <button type="submit" class="btn-add" :disabled="isSaving">➕</button>
                    </form>
                    <ul class="item-list">
                        <li v-for="serie in listas.series" :key="serie.id" class="list-item">
                            <span class="item-name">{{ serie.nom }} <span class="item-sub">T{{ serie.temporada
                                    }}</span></span>
                            <button class="btn-delete" @click="borrarSerie(serie)" title="Borrar">🗑️</button>
                        </li>
                    </ul>
                </section>

                <section class="config-card">
                    <div class="card-header">
                        <h2>Edades</h2>
                        <span class="count-badge">{{ listas.edats.length }}</span>
                    </div>
                    <form @submit.prevent="crearEdat" class="add-form">
                        <input v-model="nuevaEdat" type="number" min="0" placeholder="Ej: 16" required />
                        <button type="submit" class="btn-add" :disabled="isSaving">➕</button>
                    </form>
                    <ul class="item-list">
                        <li v-for="edat in listas.edats" :key="edat.id" class="list-item">
                            <span class="item-name">+{{ edat.edat }} años</span>
                            <button class="btn-delete" @click="borrarEdat(edat)" title="Borrar">🗑️</button>
                        </li>
                    </ul>
                </section>

                <section class="config-card">
                    <div class="card-header">
                        <h2>Niveles</h2>
                        <span class="count-badge">{{ listas.nivells.length }}</span>
                    </div>
                    <form @submit.prevent="crearNivell" class="add-form">
                        <input v-model="nuevoNivell" placeholder="Ej: Avanzado" required />
                        <button type="submit" class="btn-add" :disabled="isSaving">➕</button>
                    </form>
                    <ul class="item-list">
                        <li v-for="nivell in listas.nivells" :key="nivell.id" class="list-item">
                            <span class="item-name">{{ nivell.nivell || nivell.nom }}</span>
                            <button class="btn-delete" @click="borrarNivell(nivell)" title="Borrar">🗑️</button>
                        </li>
                    </ul>
                </section>

            </div>
        </main>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import api from '@/services/api';


const loading = ref(true);
const isSaving = ref(false);

const listas = reactive({ edats: [], nivells: [], series: [], categorias: [] });

const nuevaCategoria = ref('');
const nuevoNivell = ref('');
const nuevaEdat = ref('');
const nuevaSerie = reactive({ nom: '', temp: '' });

const loadData = async () => {
    loading.value = true;
    try {
        const data = await api.getListas();
        Object.assign(listas, data);
    } catch (e) { console.error("Error cargando listas:", e); }
    finally { loading.value = false; }
};

onMounted(loadData);

// --- FUNCIONES DE CREACIÓN ---
const crearCategoria = async () => {
    isSaving.value = true;
    try { await api.createCategoria(nuevaCategoria.value); nuevaCategoria.value = ''; await loadData(); }
    catch (e) { alert("Error: " + e.message); } finally { isSaving.value = false; }
};

const crearSerie = async () => {
    const { nom, temp } = nuevaSerie;
    isSaving.value = true;
    try { await api.createSerie(nom, temp); nuevaSerie.nom = ''; nuevaSerie.temp = ''; await loadData(); }
    catch (e) { alert("Error: " + e.message); } finally { isSaving.value = false; }
};

const crearEdat = async () => {
    isSaving.value = true;
    try { await api.createEdat(nuevaEdat.value); nuevaEdat.value = ''; await loadData(); }
    catch (e) { alert("Error: " + e.message); } finally { isSaving.value = false; }
};

const crearNivell = async () => {
    isSaving.value = true;
    try { await api.createNivell(nuevoNivell.value); nuevoNivell.value = ''; await loadData(); }
    catch (e) { alert("Error: " + e.message); } finally { isSaving.value = false; }
};

// --- FUNCIONES DE BORRADO ---
const borrarCategoria = async (cat) => {
    if (!confirm(`¿Borrar categoría "${cat.categoria || cat.nom}"?`)) return;
    try { await api.deleteCategoria(cat.id); await loadData(); }
    catch (e) { alert("Error al borrar (¿quizás está en uso por algún vídeo?): " + e.message); }
};

const borrarSerie = async (serie) => {
    if (!confirm(`¿Borrar serie "${serie.nom}" (T${serie.temporada})?`)) return;
    try { await api.deleteSerie(serie.id); await loadData(); }
    catch (e) { alert("Error al borrar: " + e.message); }
};

const borrarEdat = async (edat) => {
    if (!confirm(`¿Borrar edad "+${edat.edat}"?`)) return;
    try { await api.deleteEdat(edat.id); await loadData(); }
    catch (e) { alert("Error al borrar: " + e.message); }
};

const borrarNivell = async (nivell) => {
    if (!confirm(`¿Borrar nivel "${nivell.nivell || nivell.nom}"?`)) return;
    try { await api.deleteNivell(nivell.id); await loadData(); }
    catch (e) { alert("Error al borrar: " + e.message); }
};
</script>

<style scoped>
/* Reset y Contenedor Principal */
.config-container {
    min-height: 100vh;
    background-color: #f0f2f5;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.main-content {
    max-width: 1200px;
    margin: 0 auto;
    padding: 30px 20px;
}

/* Cabecera del Panel */
.header-section {
    background-color: #ffffff;
    padding: 20px;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    margin-bottom: 30px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.header-text h1 {
    color: #111827;
    font-size: 1.8rem;
    margin: 0 0 10px 0;
    font-weight: bold;
}

.subtitle {
    color: #4b5563;
    font-size: 1rem;
    margin: 0;
}

/* Grid de las Tarjetas */
.grid-dashboard {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 25px;
}

/* Tarjetas (Cards) */
.config-card {
    background: #ffffff;
    border: 1px solid #9ca3af;
    border-radius: 6px;
    display: flex;
    flex-direction: column;
    overflow: hidden;
}

/* Cabecera de la Tarjeta */
.card-header {
    background-color: #f3f4f6;
    border-bottom: 1px solid #9ca3af;
    padding: 15px 20px;
    display: flex;
    align-items: center;
    gap: 10px;
}

.card-header h2 {
    font-size: 1.1rem;
    color: #1f2937;
    margin: 0;
    font-weight: 700;
    text-transform: uppercase;
    flex-grow: 1;
}

.count-badge {
    background: #374151;
    color: white;
    font-size: 0.8rem;
    font-weight: bold;
    padding: 3px 8px;
    border-radius: 4px;
}

/* Formularios */
.add-form {
    display: flex;
    gap: 10px;
    padding: 20px;
    background-color: #ffffff;
    border-bottom: 1px solid #e5e7eb;
}

.add-form.double {
    display: grid;
    grid-template-columns: 2fr 1fr auto;
}

.add-form input {
    padding: 10px;
    border: 2px solid #d1d5db;
    border-radius: 4px;
    width: 100%;
}

.add-form input:focus {
    outline: none;
    border-color: #E50914;
}

.btn-add {
    background: #E50914;
    color: white;
    border: 1px solid #b9090b;
    padding: 0 15px;
    border-radius: 4px;
    cursor: pointer;
    font-weight: bold;
    display: flex;
    align-items: center;
}

.btn-add:hover:not(:disabled) {
    background: #b9090b;
}

/* Listas y Botón de Borrar */
.item-list {
    list-style: none;
    padding: 0;
    margin: 0;
    max-height: 250px;
    overflow-y: auto;
    background-color: #f9fafb;
}

.list-item {
    padding: 12px 20px;
    border-bottom: 1px solid #d1d5db;
    display: flex;
    justify-content: space-between;
    align-items: center;
    color: #374151;
    font-weight: 500;
}

.item-sub {
    color: #6b7280;
    font-weight: normal;
    margin-left: 5px;
}

/* Estilo del botón de papelera */
.btn-delete {
    background: transparent;
    border: none;
    cursor: pointer;
    font-size: 1.1rem;
    color: #dc2626;
    padding: 5px;
    border-radius: 4px;
    transition: background-color 0.2s;
}

.btn-delete:hover {
    background-color: #fee2e2;
    transform: scale(1.1);
}

/* Scrollbar */
.item-list::-webkit-scrollbar {
    width: 8px;
}

.item-list::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-left: 1px solid #d1d5db;
}

.item-list::-webkit-scrollbar-thumb {
    background: #9ca3af;
}
</style>