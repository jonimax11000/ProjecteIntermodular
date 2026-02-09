<template>
  <div class="upload-card">
    <h2>1. Archivo de Video</h2>

    <div v-if="isEditing" class="edit-warning">
      <p>⚠️ <strong>Editando:</strong> {{ originalTitle }}</p>
      <div v-if="currentThumbnail" class="mt-2">
        <p class="mini-label">📸 Miniatura Actual:</p>
        <img :src="currentThumbnail" class="thumb-preview" @error="handleError" />
      </div>
    </div>

    <div class="upload-area">
      <label class="custom-file-upload">
        <input type="file" @change="handleFile" accept="video/*" />
        <span v-if="!fileName">
          {{ isEditing ? '🔄 Cambiar Video (Opcional)' : '📂 Elegir Video MP4/MKV' }}
        </span>
        <span v-else>✅ Archivo listo: {{ fileName }}</span>
      </label>

      <div v-if="fileSize" class="file-details">
        <p><strong>Tamaño:</strong> {{ fileSize }} MB</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const props = defineProps({
  isEditing: Boolean,
  originalTitle: String,
  currentThumbnail: String
});

const emit = defineEmits(['file-selected']);

const fileName = ref('');
const fileSize = ref(0);


const handleFile = (e) => {
  const f = e.target.files[0];
  if (f) {
    fileName.value = f.name;
    fileSize.value = (f.size / (1024 * 1024)).toFixed(2);
    emit('file-selected', f);
  }
};

const handleError = (e) => e.target.src = 'https://via.placeholder.com/200x112?text=No+Img';
</script>

<style scoped>
.upload-card {
  background: white;
  padding: 25px;
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid #f0f0f0;
  margin-bottom: 20px;
}

h2 {
  color: #555;
  margin-bottom: 20px;
  border-left: 4px solid #E50914;
  padding-left: 10px;
  font-size: 1.2rem;
}

.edit-warning {
  background: #fff3cd;
  color: #856404;
  padding: 10px;
  border-radius: 5px;
  margin-bottom: 10px;
  border: 1px solid #ffeeba;
}

.mt-2 {
  margin-top: 10px;
}

.mini-label {
  font-size: 0.8rem;
  font-weight: bold;
  margin-bottom: 5px;
}

.thumb-preview {
  width: 200px;
  aspect-ratio: 16/9;
  object-fit: cover;
  border-radius: 6px;
  border: 1px solid #ccc;
  background-color: #000;
}

.upload-area {
  border: 2px dashed #E50914;
  border-radius: 8px;
  padding: 20px;
  text-align: center;
  background: #fffcfc;
  cursor: pointer;
}

.upload-area:hover {
  background: #fff5f5;
}

input[type="file"] {
  display: none;
}

.custom-file-upload {
  font-weight: bold;
  color: #E50914;
  cursor: pointer;
  display: block;
}

.file-details {
  margin-top: 10px;
  font-size: 0.9rem;
  color: #666;
}
</style>