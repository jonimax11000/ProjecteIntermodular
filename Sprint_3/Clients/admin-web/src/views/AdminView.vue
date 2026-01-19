<template>
  <div class="admin-container">
    <header>
      <h1>Panel de Administración JUSTFLIX</h1>
      <button @click="logout" class="logout-btn">Cerrar Sesión</button>
    </header>

    <div class="main-content">
      <div class="upload-card">
        <h2>1. Seleccionar Archivo</h2>
        <div class="upload-area">
          <label class="custom-file-upload">
            <input type="file" @change="onFileSelected" accept="video/*" />
            <span v-if="!fileDetails.name">📂 Elegir Video MP4/MKV</span>
            <span v-else>✅ {{ fileDetails.name }}</span>
          </label>
          
          <div v-if="fileDetails.name" class="file-details">
            <p><strong>Original:</strong> {{ fileDetails.name }}</p>
            <p v-if="formData.titol"><strong>Guardar como:</strong> {{ formData.titol }}.{{ fileExtension }}</p>
            <p><strong>Tamaño:</strong> {{ (fileDetails.size / (1024*1024)).toFixed(2) }} MB</p>
          </div>
        </div>
      </div>

      <div class="form-card" :class="{ disabled: !fileDetails.name }">
        <h2>2. Datos del Video</h2>
        
        <div class="form-grid">
          <div class="form-group full-width">
            <label>Título (Nombre del archivo):</label>
            <input v-model="formData.titol" type="text" placeholder="Ej: Matrix" />
          </div>

          <div class="form-group full-width">
            <label>Descripción:</label>
            <textarea v-model="formData.descripcion" placeholder="Descripción del contenido..."></textarea>
          </div>

          <div class="form-group">
            <div class="label-action">
              <label>Clasificación Edad <span style="color:red">*</span>:</label>
              <button @click="isCreatingEdat = !isCreatingEdat" class="mini-btn">
                {{ isCreatingEdat ? '✖ Cancelar' : '✚ Crear Edad' }}
              </button>
            </div>
            
            <select v-if="!isCreatingEdat" v-model="formData.edat">
              <option :value="null" disabled>Selecciona edad...</option>
              <option v-for="e in dbEdats" :key="e.id" :value="e.id">
                +{{ e.edat }} años (ID: {{ e.id }})
              </option>
            </select>

            <div v-else class="mini-form">
              <input v-model="newEdatValue" type="number" placeholder="Ej: 13" />
              <button @click="createEdat" class="save-mini-btn">Guardar</button>
            </div>
          </div>

          <div class="form-group">
            <div class="label-action">
              <label>Nivel Requerido <span style="color:red">*</span>:</label>
              <button @click="isCreatingNivell = !isCreatingNivell" class="mini-btn">
                {{ isCreatingNivell ? '✖ Cancelar' : '✚ Crear Nivel' }}
              </button>
            </div>

            <select v-if="!isCreatingNivell" v-model="formData.nivellDummy">
              <option :value="null" disabled>Selecciona nivel...</option>
              <option v-for="n in dbNivells" :key="n.id" :value="n.id">
                Nivel {{ n.nivell }} (ID: {{ n.id }})
              </option>
            </select>

            <div v-else class="mini-form">
              <input v-model="newNivellValue" type="number" placeholder="Ej: 4" />
              <button @click="createNivell" class="save-mini-btn">Guardar</button>
            </div>
          </div>

          <div class="form-group full-width serie-box">
            <div class="toggle-header">
              <label>Serie:</label>
              <div class="toggle-btns">
                <span @click="isNewSerie = false" :class="{active: !isNewSerie}">Existente</span>
                <span @click="isNewSerie = true" :class="{active: isNewSerie}">Crear Nueva</span>
              </div>
            </div>

            <div v-if="!isNewSerie" class="mt-2">
              <select v-model="formData.serie">
                <option :value="null">-- Ninguna (Video suelto / Película) --</option>
                <option v-for="s in dbSeries" :key="s.id" :value="s.id">
                  {{ s.nom }} (Temp: {{ s.temporada }})
                </option>
              </select>
            </div>

            <div v-else class="new-serie-form mt-2">
              <input v-model="newSerieData.nom" type="text" placeholder="Nombre de la nueva serie" />
              <input v-model="newSerieData.temporada" type="number" placeholder="Temporada (ej: 1)" />
            </div>
          </div>

          <div class="form-group full-width">
             <div class="label-action">
              <label>Categorías <span style="color:red">*</span>:</label>
              <button @click="isCreatingCat = !isCreatingCat" class="mini-btn">
                {{ isCreatingCat ? '✖ Cancelar' : '✚ Crear Categoría' }}
              </button>
            </div>

            <div v-if="!isCreatingCat">
              <div class="checkbox-container">
                <label v-for="c in dbCategorias" :key="c.id" class="checkbox-pill">
                  <input type="checkbox" :value="c.id" v-model="formData.categories">
                  {{ c.categoria }}
                </label>
              </div>
              <small v-if="formData.categories.length === 0" style="color: #999;">Selecciona al menos una categoría</small>
            </div>

            <div v-else class="mini-form">
              <input v-model="newCatValue" type="text" placeholder="Ej: Anime, Terror..." />
              <button @click="createCategoria" class="save-mini-btn">Guardar</button>
            </div>
          </div>
        </div>

        <button 
          @click="submitVideo" 
          :disabled="isUploading || !formData.titol"
          class="submit-btn"
        >
          {{ isUploading ? uploadStatus : '🚀 Guardar en Catálogo' }}
        </button>

        <div v-if="message" :class="['status-msg', isSuccess ? 'success' : 'error']">
          {{ message }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

const router = useRouter()

// Estados
const isUploading = ref(false)
const uploadStatus = ref('') 
const message = ref('')
const isSuccess = ref(false)
const selectedFileRaw = ref(null) 

// Listas BD
const dbEdats = ref([])
const dbNivells = ref([]) 
const dbSeries = ref([])
const dbCategorias = ref([])

// Archivo
const fileDetails = reactive({ name: '', size: 0 })
const fileExtension = computed(() => fileDetails.name ? fileDetails.name.split('.').pop() : '')

// Toggles
const isNewSerie = ref(false)
const isCreatingEdat = ref(false)   
const isCreatingNivell = ref(false) 
const isCreatingCat = ref(false) // NUEVO

// Temporales
const newSerieData = reactive({ nom: '', temporada: 1 })
const newEdatValue = ref('')
const newNivellValue = ref('')
const newCatValue = ref('') // NUEVO

// Formulario Principal
const formData = reactive({
  titol: '',
  descripcion: '', 
  edat: null,       
  nivellDummy: null, 
  serie: null,
  categories: [] 
})

// 1. CARGAR DATOS (PROXY)
const loadAllData = async () => {
  try {
    const [resEdat, resNivell, resSeries, resCat] = await Promise.all([
      axios.get('/api/edats'),       
      axios.get('/api/nivells'),     
      axios.get('/api/series'),      
      axios.get('/api/categories')   
    ])
    dbEdats.value = resEdat.data
    dbNivells.value = resNivell.data
    dbSeries.value = resSeries.data
    dbCategorias.value = resCat.data
  } catch (e) {
    console.error("Error conectando con SpringBoot:", e)
    message.value = "Error: No se conecta con el Backend Java."
  }
}

onMounted(() => {
  loadAllData()
})

// 2. CREAR EDAD
const createEdat = async () => {
  if (!newEdatValue.value) return alert("Escribe una edad")
  const valor = parseInt(newEdatValue.value)
  const existeLocal = dbEdats.value.find(e => e.edat === valor)
  if (existeLocal) {
    formData.edat = existeLocal.id
    isCreatingEdat.value = false
    newEdatValue.value = ''
    return 
  }
  try {
    await axios.post('/api/edats', { edat: valor })
    const res = await axios.get('/api/edats')
    dbEdats.value = res.data
    const creada = dbEdats.value.find(e => e.edat === valor)
    if (creada) formData.edat = creada.id
    isCreatingEdat.value = false; newEdatValue.value = ''
  } catch (error) { console.error(error); alert("Error al guardar la edad.") }
}

// 3. CREAR NIVEL
const createNivell = async () => {
  if (!newNivellValue.value) return alert("Escribe un nivel")
  const valor = parseInt(newNivellValue.value)
  const existeLocal = dbNivells.value.find(n => n.nivell === valor)
  if (existeLocal) {
    formData.nivellDummy = existeLocal.id
    isCreatingNivell.value = false
    newNivellValue.value = ''
    return 
  }
  try {
    await axios.post('/api/nivells', { nivell: valor })
    const res = await axios.get('/api/nivells')
    dbNivells.value = res.data
    const creado = dbNivells.value.find(n => n.nivell === valor)
    if (creado) formData.nivellDummy = creado.id
    isCreatingNivell.value = false; newNivellValue.value = ''
  } catch (error) { console.error(error); alert("Error al guardar el nivel.") }
}

// 4. CREAR CATEGORÍA (NUEVO)
const createCategoria = async () => {
  if (!newCatValue.value) return alert("Escribe el nombre de la categoría")
  const nombre = newCatValue.value

  // Comprobar si ya existe (ignorando mayúsculas)
  const existeLocal = dbCategorias.value.find(c => c.categoria.toLowerCase() === nombre.toLowerCase())
  if (existeLocal) {
    // Si ya existe, la marcamos automáticamente
    if (!formData.categories.includes(existeLocal.id)) {
      formData.categories.push(existeLocal.id)
    }
    isCreatingCat.value = false
    newCatValue.value = ''
    return
  }

  try {
    // IMPORTANTE: Si tu backend tenía el typo, esto fallará y tendrás que poner '/api/ategories'
    // Asumo que está corregido o usamos el estándar '/api/categories'
    await axios.post('/api/categories', { categoria: nombre })
    
    const res = await axios.get('/api/categories')
    dbCategorias.value = res.data
    
    // Buscar la nueva y seleccionarla
    const creada = dbCategorias.value.find(c => c.categoria === nombre)
    if (creada) {
       formData.categories.push(creada.id)
    }
    
    isCreatingCat.value = false
    newCatValue.value = ''
  } catch (error) {
    console.error(error)
    alert("Error al crear categoría. (Si falla 404, revisa si tu backend tiene el typo '/api/ategories')")
  }
}

// 5. SELECCIÓN ARCHIVO
const onFileSelected = (event) => {
  const file = event.target.files[0]
  if (file) {
    selectedFileRaw.value = file
    fileDetails.name = file.name
    fileDetails.size = file.size
    if (!formData.titol) {
        formData.titol = file.name.replace(/\.[^/.]+$/, "")
    }
  }
}

// 6. SUBIR VIDEO Y CREAR RELACIONES
const submitVideo = async () => {
  if (!selectedFileRaw.value) return alert("Por favor, selecciona un archivo de vídeo.")
  if (!formData.edat) return alert("⚠️ Clasificación de Edad obligatoria.")
  if (!formData.nivellDummy) return alert("⚠️ Nivel Requerido obligatorio.")
  if (!formData.titol) return alert("⚠️ Título obligatorio.")
  if (formData.categories.length === 0) return alert("⚠️ Selecciona al menos una Categoría.")

  isUploading.value = true
  message.value = ''
  isSuccess.value = false
  
  try {
    // A) SUBIR VIDEO (3000)
    uploadStatus.value = '1/3 Renombrando y subiendo...'
    const uploadData = new FormData()
    const nuevoNombreArchivo = `${formData.titol}.${fileExtension.value}`
    uploadData.append('video', selectedFileRaw.value, nuevoNombreArchivo) 
    
    const resUpload = await axios.post('http://localhost:3000/api/video', uploadData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    const videoMetadata = resUpload.data

    // B) GESTIONAR SERIE
    uploadStatus.value = '2/3 Verificando serie...'
    let serieIdFinal = formData.serie 

    if (isNewSerie.value && newSerieData.nom) {
      try {
        await axios.post('/api/series', {
            nom: newSerieData.nom,
            temporada: newSerieData.temporada,
            videos: [] 
        })
      } catch (err) { }
      
      const resSeries = await axios.get('/api/series')
      dbSeries.value = resSeries.data
      const serieEncontrada = dbSeries.value.find(s => s.nom === newSerieData.nom)
      if (serieEncontrada) serieIdFinal = serieEncontrada.id
    }

    // C) GUARDAR EN JAVA
    uploadStatus.value = '3/3 Guardando datos y relaciones...'
    const categoriasIds = formData.categories.map(id => parseInt(id))

    const videoDTO = {
      titol: formData.titol, 
      videoURL: videoMetadata.videoUrl, 
      thumbnailURL: videoMetadata.thumbnail, 
      duracio: parseInt(videoMetadata.duracio || 0), 
      serie: serieIdFinal, 
      edat: formData.edat, 
      nivell: formData.nivellDummy, 
      categories: categoriasIds 
    }

    await axios.post('/api/cataleg', videoDTO)

    isSuccess.value = true
    message.value = `¡Éxito! Video guardado y vinculado correctamente.`
    
    formData.titol = ''
    formData.categories = [] 
    fileDetails.name = ''
    selectedFileRaw.value = null

  } catch (error) {
    console.error("❌ ERROR:", error)
    isSuccess.value = false
    
    if (error.response) {
       message.value = `Error Backend (${error.response.status}): ${JSON.stringify(error.response.data)}`
    } else {
      message.value = 'Error de conexión.'
    }
  } finally {
    isUploading.value = false
    uploadStatus.value = ''
  }
}

const logout = () => {
  localStorage.removeItem('user') 
  router.push('/')
}
</script>

<style scoped>
/* ESTILOS IDENTICOS */
.admin-container { max-width: 900px; margin: 0 auto; padding: 20px; font-family: 'Segoe UI', sans-serif; color: #333; }
header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 2px solid #eee; padding-bottom: 15px; }
h1 { font-size: 1.5rem; margin: 0; }
.main-content { display: grid; grid-template-columns: 1fr 1.5fr; gap: 30px; }
@media (max-width: 768px) { .main-content { grid-template-columns: 1fr; } }
.upload-card, .form-card { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid #f0f0f0; }
.form-card.disabled { opacity: 0.6; pointer-events: none; }
h2 { color: #555; margin-bottom: 20px; border-left: 4px solid #E50914; padding-left: 10px; font-size: 1.2rem; }
.upload-area { border: 2px dashed #E50914; border-radius: 8px; padding: 20px; text-align: center; background: #fffcfc; transition: 0.3s; }
.upload-area:hover { background: #fff5f5; }
input[type="file"] { display: none; }
.custom-file-upload { display: block; font-weight: bold; color: #E50914; cursor: pointer; padding: 10px;}
.file-details { margin-top: 10px; background: #f9f9f9; padding: 10px; border-radius: 5px; font-size: 0.9rem; border: 1px solid #eee; }
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
.full-width { grid-column: span 2; }
.label-action { display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px; }
label { font-weight: 600; font-size: 0.9rem; }
.mini-btn { background: none; border: none; color: #E50914; font-size: 0.8rem; cursor: pointer; font-weight: bold; }
.mini-btn:hover { text-decoration: underline; }
.mini-form { display: flex; gap: 5px; }
.save-mini-btn { background: #333; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; font-size: 0.8rem; }
input, select, textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; }
textarea { height: 80px; resize: vertical; }
.serie-box { background: #fafafa; padding: 15px; border-radius: 8px; border: 1px solid #eee; }
.toggle-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
.toggle-btns span { font-size: 0.85rem; padding: 6px 12px; cursor: pointer; border: 1px solid #ddd; background: white; }
.toggle-btns span:first-child { border-radius: 4px 0 0 4px; }
.toggle-btns span:last-child { border-radius: 0 4px 4px 0; border-left: none; }
.toggle-btns span.active { background: #333; color: white; border-color: #333; }
.new-serie-form input { margin-bottom: 8px; }
.mt-2 { margin-top: 10px; }
.checkbox-container { display: flex; flex-wrap: wrap; gap: 8px; }
.checkbox-pill { background: #f5f5f5; padding: 6px 12px; border-radius: 20px; font-size: 0.85rem; cursor: pointer; border: 1px solid #ddd; display: flex; align-items: center; gap: 5px; }
.checkbox-pill:has(input:checked) { background: #E50914; color: white; border-color: #E50914; }
.submit-btn { background: #E50914; color: white; width: 100%; padding: 15px; border: none; border-radius: 8px; font-size: 1.1rem; font-weight: bold; cursor: pointer; margin-top: 20px; transition: 0.3s; }
.submit-btn:hover:not(:disabled) { background: #b2070f; }
.submit-btn:disabled { background: #ccc; cursor: not-allowed; }
.logout-btn { background: #333; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-size: 0.9rem; }
.status-msg { margin-top: 15px; padding: 10px; text-align: center; border-radius: 6px; font-weight: bold; }
.success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
.error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
</style>