<template>
  <div class="login-container">
    <div class="card">
      <h2>Acceso Administración</h2>
      <form @submit.prevent="handleLogin">
        <div class="form-group">
          <label>Usuario:</label>
          <input v-model="username" type="text" placeholder="admin" required />
        </div>
        
        <div class="form-group">
          <label>Contraseña:</label>
          <input v-model="password" type="password" placeholder="1234" required />
        </div>

        <button type="submit">Entrar</button>
      </form>
      <p v-if="error" class="error">{{ error }}</p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const username = ref('')
const password = ref('')
const error = ref('')
const router = useRouter()

const handleLogin = () => {
  if (username.value === 'admin' && password.value === '1234') {
    localStorage.setItem('token', 'sesion-iniciada-ok')
    router.push('/admin')
  } else {
    error.value = 'Usuario o contraseña incorrectos'
  }
}
</script>

<style scoped>
.login-container { display: flex; justify-content: center; margin-top: 50px; }
.card { border: 1px solid #ddd; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); width: 300px; }
.form-group { margin-bottom: 15px; }
input { width: 100%; padding: 8px; margin-top: 5px; box-sizing: border-box; }
button { width: 100%; padding: 10px; background: #42b983; color: white; border: none; cursor: pointer; }
.error { color: red; font-size: 0.9em; margin-top: 10px; text-align: center; }
</style>