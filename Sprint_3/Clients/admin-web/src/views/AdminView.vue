<template>

  <div class="admin-container">

    <div class="main-content">
      <FileUploader :isEditing="isEditing" :originalTitle="originalTitle" :currentThumbnail="currentUrls.thumbnail"
        @file-selected="(f) => selectedFileRaw = f" />

      <VideoForm v-if="formData" :form-data="formData" :listas="listasDB" :isUploading="isUploading"
        :statusText="uploadStatus" :isEditing="isEditing" @update:formData="(newData) => formData = newData"
        @submit="submitVideo" @add-serie="handleAddSerie" @add-edat="handleAddEdat" @add-nivell="handleAddNivell"
        @add-categoria="handleAddCategoria" />
    </div>
    <div class="header-actions">
      <router-link to="/lista" class="cta-upload">Lista de vídeos</router-link>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import api from '@/services/api';
import FileUploader from '@/components/admin/FileUploader.vue';
import VideoForm from '@/components/admin/VideoForm.vue';

const router = useRouter();
const route = useRoute();

// Estados de carga
const isUploading = ref(false);
const uploadStatus = ref('');
const selectedFileRaw = ref(null);
const clientId = ref(null);
const socket = ref(null);
const processingResolvers = new Map(); // jobId -> {resolve, reject}

// Estados de edición
const isEditing = ref(false);
const currentVideoId = ref(null);
const originalTitle = ref('');
const currentUrls = reactive({ video: '', thumbnail: '', duracio: 0 });

// Listas para los desplegables
const listasDB = reactive({ edats: [], nivells: [], series: [], categorias: [] });

// Datos del formulario
const formData = ref({
  titol: '',
  descripcio: '',
  edat: null,
  nivellDummy: null, // "nivellDummy" para mapearlo luego a "nivell"
  serie: null,
  categories: []
});

// --- CARGA DE DATOS ---

const setupWebSocket = () => {
    // Generate a simple client ID if not exists
    clientId.value = "client_" + Math.random().toString(36).substr(2, 9);
    console.log("WebSocket: Connecting with ID", clientId.value);

    // Connect to WebSocket server through Vite proxy
    const wsUrl = `ws://${window.location.host}/ws`;
    console.log("WebSocket URL:", wsUrl);
    socket.value = new WebSocket(wsUrl);

    socket.value.onopen = () => {
        console.log("WebSocket connected");
        // Register client
        socket.value.send(JSON.stringify({
            type: 'register',
            clientId: clientId.value
        }));
    };

    socket.value.onmessage = (event) => {
        try {
            const data = JSON.parse(event.data);
            console.log("WebSocket received:", data);

            switch (data.type) {
                case 'processing_started':
                    uploadStatus.value = `Procesando: ${data.message}`;
                    break;
                case 'processing_completed':
                    uploadStatus.value = `¡Completado! ${data.message}`;
                    if (data.jobId && processingResolvers.has(data.jobId)) {
                        processingResolvers.get(data.jobId).resolve(data);
                        processingResolvers.delete(data.jobId);
                    }
                    break;
                case 'processing_error':
                    uploadStatus.value = `Error: ${data.message}`;
                    if (data.jobId && processingResolvers.has(data.jobId)) {
                        processingResolvers.get(data.jobId).reject(new Error(data.message));
                        processingResolvers.delete(data.jobId);
                    }
                    alert(`Error en el procesamiento: ${data.message}`);
                    break;
                case 'registered':
                    console.log("Client registered successfully");
                    break;
            }
        } catch (e) {
            console.error("Error parsing WebSocket message", e);
        }
    };

    socket.value.onerror = (error) => {
        console.error("WebSocket error:", error);
    };

    socket.value.onclose = () => {
        console.log("WebSocket connection closed");
    };
};

const refreshLists = async () => {
  try {
    const data = await api.getListas();
    Object.assign(listasDB, data);
  } catch (e) {
    console.error("Error cargando listas:", e);
  }
};

  onMounted(async () => {
    try {
      await refreshLists();
      // Si hay ?edit=123 en la URL, cargamos modo edición
      if (route.query.edit) {
        await loadVideoForEdit(route.query.edit);
      }
      setupWebSocket();
    } catch (e) {
      console.error(e);
    }
  });

  onUnmounted(() => {
    if (socket.value) {
      socket.value.close();
    }
  });

// --- FUNCIONES PARA CREAR NUEVOS ELEMENTOS (MODALES/PROMPTS) ---

const handleAddCategoria = async () => {
  const nombre = prompt("Escribe el nombre de la nueva categoría (ej: Acción):");
  if (!nombre) return;
  try {
    await api.createCategoria(nombre);
    await refreshLists();
    alert(`Categoría "${nombre}" creada.`);
  } catch (e) {
    alert("Error creando categoría: " + e.message);
  }
};

const handleAddSerie = async () => {
  let nombre = prompt("Escribe el nombre de la nueva serie:");
  if (!nombre) return;
  nombre = nombre.trim();

  const temp = prompt(`¿Qué temporada es "${nombre}"?`, "1");
  if (!temp) return;
  const tempNum = parseInt(temp);

  const existe = listasDB.series.some(s =>
    s.nom.toLowerCase() === nombre.toLowerCase() &&
    s.temporada === tempNum
  );

  if (existe) {
    alert(`⚠️ ¡Error! La serie "${nombre}" (Temporada ${tempNum}) YA EXISTE.`);
    return;
  }

  try {
    await api.createSerie(nombre, temp);
    await refreshLists();
    alert(`✅ Serie "${nombre}" (T${temp}) creada.`);
  } catch (e) {
    alert("Error creando serie: " + e.message);
  }
};

const handleAddEdat = async () => {
  const valor = prompt("Escribe la nueva edad (ej: 18):");
  if (!valor) return;
  try {
    await api.createEdat(valor);
    await refreshLists();
    alert(`Edad "+${valor}" creada.`);
  } catch (e) {
    alert("Error creando edad: " + e.message);
  }
};

const handleAddNivell = async () => {
  const valor = prompt("Escribe el nuevo nivel (ej: 1):");
  if (!valor) return;
  try {
    await api.createNivell(valor);
    await refreshLists();
    alert(`Nivel "${valor}" creado.`);
  } catch (e) {
    alert("Error creando nivel: " + e.message);
  }
};


// --- LOGICA DE EDICIÓN EN AdminView.vue ---

const loadVideoForEdit = async (id) => {
  const v = await api.getVideo(id);
  if (!v) return;

  isEditing.value = true;
  currentVideoId.value = v.id;
  originalTitle.value = v.titol;


  formData.value = {
    titol: v.titol,
    descripcio: v.descripcio || '',
    edat: v.edat?.id || v.edat,
    nivellDummy: v.nivell?.id || v.nivell,
    serie: v.serie?.id || v.serie,
    categories: v.categories?.[0]?.id ? v.categories.map(c => c.id) : (v.categories || [])
  };

  currentUrls.video = v.videoURL || v.url;
  currentUrls.duracio = v.duracio;

  const thumbName = v.thumbnailURL || v.thumbnail;
  const nivel = v.nivell?.id || v.nivell;

  currentUrls.thumbnail = api.getThumbnailUrl(thumbName, nivel);
};

// --- ENVÍO DEL FORMULARIO (SUBMIT) ---

const submitVideo = async () => {
  if (!formData.value.titol) return alert('Pon un título');

  isUploading.value = true;
  try {
    let finalUrl = currentUrls.video;
    let finalThumb = currentUrls.thumbnail;
    let finalDur = currentUrls.duracio;
    let fileSize = 1024000; // Valor por defecto ~1MB si no se sube archivo nuevo

    // 1. SUBIDA A NODE (Si el usuario seleccionó un archivo)
    if (selectedFileRaw.value) {
      if (isEditing.value && finalUrl) {
        api.deleteFileNode(finalUrl, finalThumb).catch(() => { });
      }

      uploadStatus.value = 'Subiendo video a Node...';

      const cleanTitle = formData.value.titol.trim();
      const ext = selectedFileRaw.value.name.split('.').pop();
      const forcedName = `${cleanTitle}.${ext}`;
      const forcedThumb = `${cleanTitle}.jpg`.toLowerCase();

      const nivelParaNode = formData.value.nivellDummy;

      fileSize = selectedFileRaw.value.size;
      // Pass clientId to API
      const nodeRes = await api.uploadVideoNode(selectedFileRaw.value, forcedName, nivelParaNode, clientId.value);


      console.log(nodeRes);


      if (nodeRes.jobId) {
          uploadStatus.value = "Esperando procesamiento del servidor (FFmpeg)...";
          // Esperar a que el WebSocket nos confirme que terminó
          const processResult = await new Promise((resolve, reject) => {
              processingResolvers.set(nodeRes.jobId, { resolve, reject });
          });

          console.log("Procesamiento finalizado, datos recibidos:", processResult);
          
          if (processResult.videoData) {
            finalUrl = processResult.videoData.videoUrl || forcedName;
            finalThumb = processResult.videoData.thumbnail || forcedThumb;
            finalDur = processResult.videoData.duracio || 0;
            fileSize = processResult.videoData.fileSize || fileSize;
          }
      } else {
        // Fallback si no hay jobId
        finalUrl = forcedName;
        finalThumb = forcedThumb;
        finalDur = Number(nodeRes.duracio) || 0;
      }
    }

    // 2. DATOS PARA JAVA (BASE DE DATOS)
    // Fecha de hoy para createdAt
    const today = new Date().toISOString().split('T')[0];

    const payload = {
      titol: formData.value.titol,
      videoURL: finalUrl,
      thumbnailURL: finalThumb,
      descripcio: formData.value.descripcio,
      duracio: parseInt(finalDur),

      // IDs SIMPLES (Enteros), tal como pide el JSON de tu compañero
      serie: formData.value.serie ? parseInt(formData.value.serie) : null,
      edat: parseInt(formData.value.edat),
      nivell: parseInt(formData.value.nivellDummy),

      // Array de enteros
      categories: formData.value.categories.map(id => parseInt(id)),

      // METADATOS (Objeto obligatorio nuevo)
      metadades: {
        width: 1920,
        height: 1080,
        fps: 30,
        bitrate: 5000,
        codec: "H.264",
        fileSize: fileSize,
        createdAt: today
      }
    };

    uploadStatus.value = 'Guardando datos en Spring Boot...';

    // Enviamos a Java
    await api.saveVideoJava(payload);

    // Borrado lógico antiguo si editamos (Create-Delete pattern)
    if (isEditing.value) {
      await api.deleteVideoJava(currentVideoId.value).catch(() => { });
    }

    alert('¡Video guardado correctamente!');
    router.push('/lista');

  } catch (e) {
    console.error("Error al guardar:", e);
    // Mostrar detalles si es error del servidor
    if (e.response && e.response.data) {
      alert('Error del servidor: ' + JSON.stringify(e.response.data));
    } else {
      alert('Error al guardar: ' + e.message);
    }
  } finally {
    isUploading.value = false;
  }
};
</script>

<style scoped>
.admin-container {
  max-width: 900px;
  margin: 0 auto;
  padding: 20px;
  font-family: 'Segoe UI', sans-serif;
}

.main-content {
  display: grid;
  grid-template-columns: 1fr 1.5fr;
  gap: 30px;
}

.cta-upload {
  background: #ff0000;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
}

@media (max-width: 768px) {
  .main-content {
    grid-template-columns: 1fr;
  }
}
</style>