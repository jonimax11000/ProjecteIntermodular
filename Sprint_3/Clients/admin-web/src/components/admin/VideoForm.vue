<template>
  <div class="form-card">
    <h2>2. Datos del Video</h2>

    <div v-if="formData" class="form-grid">
      
      <div class="full-width">
        <label>Título:</label>
        <input 
          :value="formData.titol" 
          @input="updateField('titol', $event.target.value)"
          type="text" placeholder="Ej: Matrix" 
        />
      </div>

      <div class="full-width">
        <label>Descripción:</label>
        <textarea 
          :value="formData.descripcio"
          @input="updateField('descripcio', $event.target.value)"
        ></textarea>
      </div>

      <div>
        <label>Edad:</label>
        <div class="select-group">
            <select :value="formData.edat" @change="updateField('edat', $event.target.value)">
            <option :value="null">Selecciona...</option>
            <option v-for="e in listas.edats" :key="e.id" :value="e.id">+{{ e.edat }}</option>
            </select>
            <button class="add-btn" @click.prevent="$emit('add-edat')" title="Nueva Edad">+</button>
        </div>
      </div>

      <div>
        <label>Nivel:</label>
        <div class="select-group">
            <select :value="formData.nivellDummy" @change="updateField('nivellDummy', $event.target.value)">
            <option :value="null">Selecciona...</option>
            <option v-for="n in listas.nivells" :key="n.id" :value="n.id">{{ n.nivell }}</option>
            </select>
            <button class="add-btn" @click.prevent="$emit('add-nivell')" title="Nuevo Nivel">+</button>
        </div>
      </div>

      <div class="full-width">
        <label>Serie (Opcional):</label>
        <div class="select-group">
            <select :value="formData.serie" @change="updateField('serie', $event.target.value)">
            <option :value="null">-- Película (Sin Serie) --</option>
            
            <option v-for="s in listas.series" :key="s.id" :value="s.id">
                {{ s.nom }} {{ s.temporada ? `(T${s.temporada})` : '' }}
            </option>
            </select>
            <button class="add-btn" @click.prevent="$emit('add-serie')" title="Nueva Serie">+</button>
        </div>
      </div>

<div class="full-width">
        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
            <label style="margin-bottom: 0;">Categorías:</label>
            <button class="add-btn" @click.prevent="$emit('add-categoria')" title="Nueva Categoría">+</button>
        </div>

        <div class="checkbox-container">
           <label v-for="c in listas.categorias" :key="c.id" class="checkbox-pill">
              <input 
                type="checkbox" 
                :checked="formData.categories && formData.categories.includes(c.id)"
                @change="toggleCat(c.id)"
              > {{ c.categoria }}
           </label>
        </div>
      </div>
    </div>

    <button 
      @click="$emit('submit')" 
      :disabled="isUploading"
      class="submit-btn"
    >
      {{ isUploading ? statusText : (isEditing ? '💾 Guardar Cambios' : '🚀 Guardar Video') }}
    </button>
  </div>
</template>

<script setup>
const props = defineProps({
  formData: Object,
  listas: Object,
  isUploading: Boolean,
  statusText: String,
  isEditing: Boolean
});

const emit = defineEmits(['update:formData', 'submit', 'add-serie', 'add-edat', 'add-nivell', 'add-categoria']);
const updateField = (field, value) => {
  if (!props.formData) return;
  emit('update:formData', { ...props.formData, [field]: value });
};

const toggleCat = (id) => {
  if (!props.formData) return;
  const newCats = [...(props.formData.categories || [])]; 
  const idx = newCats.indexOf(id);
  if (idx > -1) newCats.splice(idx, 1);
  else newCats.push(id);
  emit('update:formData', { ...props.formData, categories: newCats });
};
</script>

<style scoped>
.form-card { background: white; padding: 25px; border-radius: 12px; border: 1px solid #f0f0f0; }
h2 { color: #555; margin-bottom: 20px; border-left: 4px solid #E50914; padding-left: 10px; font-size: 1.2rem; }
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
.full-width { grid-column: span 2; }
label { font-weight: 600; display: block; margin-bottom: 5px; font-size: 0.9rem;}

/* Estilo para poner el select y el botón juntos */
.select-group { display: flex; gap: 5px; }
select { flex-grow: 1; } /* El select ocupa todo el espacio posible */

input, select, textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; }

/* Botón pequeñito (+) */
.add-btn {
    background: #444; color: white; border: none; width: 40px; border-radius: 6px; 
    font-size: 1.2rem; cursor: pointer; transition: background 0.2s;
}
.add-btn:hover { background: #E50914; }

.checkbox-container { display: flex; gap: 10px; flex-wrap: wrap; }
.checkbox-pill { background: #f5f5f5; padding: 5px 12px; border-radius: 20px; display: flex; gap: 5px; align-items: center; cursor: pointer; border: 1px solid #eee; }
.checkbox-pill:has(input:checked) { background: #E50914; color: white; border-color: #E50914; }
.submit-btn { width: 100%; padding: 15px; background: #E50914; color: white; border: none; border-radius: 8px; font-weight: bold; cursor: pointer; margin-top: 20px; }
.submit-btn:disabled { background: #ccc; }
</style>