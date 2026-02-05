<template>
  <div class="list-container">
    <div class="header-actions">
      <router-link to="/admin" class="cta-upload">✚ Subir Nuevo Video</router-link>
    </div>

    <div v-if="loading" class="loading">Cargando catálogo...</div>

    <div v-else class="video-grid">
      <div v-for="video in videos" :key="video.id" class="video-card" @click="editVideo(video.id)">
        <div class="thumb-wrapper">
          <img :src="getThumb(video.thumbnailURL || video.thumbnail, video.nivell?.id || video.nivell)"
            @error="handleErr" /> <span class="duration">{{ formatTime(video.duracio) }}</span>
        </div>
        <div class="info">
          <h3>{{ video.titol }}</h3>
          <div class="info-footer">
            <p>{{ video.serie ? '📺 Serie' : '🎬 Película' }}</p>
            <button class="btn-delete" @click.stop="deleteVideo(video)" title="Borrar vídeo">
              🗑️
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import api from '@/services/api';

const router = useRouter();
const videos = ref([]);
const loading = ref(true);

onMounted(async () => {
  try {
    // Recuerda que 'getCatalogo' debe estar en tu api.js
    videos.value = await api.getCatalogo();
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
});

// Helpers de visualización
const getThumb = (name, nivel) => api.getThumbnailUrl(name, nivel);
const handleErr = (e) => e.target.src = 'https://via.placeholder.com/300x169?text=Error';
const formatTime = (m) => m ? `${m} min` : '0 min';

// Navegación a edición
const editVideo = (id) => router.push({ path: '/admin', query: { edit: id } });

// Lógica de borrado
const deleteVideo = async (video) => {
  if (confirm(`¿Estás seguro de que quieres borrar "${video.titol}" para siempre?`)) {
    try {
      // 1. Borramos de Java (Base de datos)
      await api.deleteVideoJava(video.id);

      // 2. Borramos de Node (Archivos físicos en el disco duro)
      // Usamos el nombre del archivo de video y la miniatura
      const videoName = video.videoURL || video.url;
      const thumbName = video.thumbnailURL || video.thumbnail;
      if (videoName) {
        await api.deleteFileNode(videoName, thumbName).catch(() => { });
      }

      // 3. Quitamos el vídeo de la lista visualmente sin recargar la página
      videos.value = videos.value.filter(v => v.id !== video.id);

    } catch (e) {
      alert("Error al borrar: " + e.message);
    }
  }
};
</script>

<style scoped>
.list-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  font-family: 'Segoe UI', sans-serif;
}

.header-actions {
  margin-bottom: 20px;
}

.cta-upload {
  display: inline-block;
  background: #E50914;
  color: white;
  padding: 10px 20px;
  text-decoration: none;
  border-radius: 5px;
  font-weight: bold;
}

.loading {
  text-align: center;
  padding: 40px;
  font-size: 1.2rem;
  color: #666;
}

.video-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 20px;
}

.video-card {
  cursor: pointer;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s;
  background: white;
}

.video-card:hover {
  transform: translateY(-5px);
}

.thumb-wrapper {
  aspect-ratio: 16/9;
  background: #000;
  position: relative;
}

.thumb-wrapper img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.duration {
  position: absolute;
  bottom: 5px;
  right: 5px;
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 2px 5px;
  font-size: 0.8rem;
  border-radius: 3px;
}

.info {
  padding: 10px;
}

.info h3 {
  margin: 0;
  font-size: 1rem;
  color: #333;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Nuevos estilos para la parte inferior de la tarjeta */
.info-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
}

.info-footer p {
  margin: 0;
  color: #666;
  font-size: 0.8rem;
}

.btn-delete {
  background: none;
  border: none;
  font-size: 1.2rem;
  cursor: pointer;
  padding: 0;
  transition: transform 0.1s;
}

.btn-delete:hover {
  transform: scale(1.2);
}
</style>