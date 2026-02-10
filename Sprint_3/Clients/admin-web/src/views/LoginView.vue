<template>
  <div class="login-container">
    <div class="login-card">
      <h1>JUSTFLIX</h1>
      <p>Panel de Administración</p>

      <form @submit.prevent="handleLogin">
        <div class="form-group">
          <label>Correo Electrónico</label>
          <input v-model="username" type="email" placeholder="email" required autofocus />
        </div>

        <div class="form-group">
          <label>Contraseña</label>
          <input v-model="password" type="password" placeholder="Contraseña" required />
        </div>

        <button type="submit" :disabled="isLoading" class="login-btn">
          {{ isLoading ? 'Conectando con Odoo...' : 'Entrar' }}
        </button>
      </form>

      <div v-if="error" class="error-box">
        <p>{{ error }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import api from '@/services/api';

const router = useRouter();

const username = ref('');
const password = ref('');
const error = ref('');
const isLoading = ref(false);

const handleLogin = async () => {
  error.value = '';
  isLoading.value = true;

  try {
    const dataOdoo = await api.login(username.value, password.value);

    console.log("Datos recibidos en LoginView:", dataOdoo);

    const token = dataOdoo.token;

    if (token) {
      localStorage.setItem('jwt_token', token);
      localStorage.setItem('user', username.value);

      if (dataOdoo.refreshToken) {
        console.log("✅ ¡Refresh Token recibido y guardado!");
        localStorage.setItem('refresh_token', dataOdoo.refreshToken);
      } else {
        console.log("❌ ¡Refresh Token no ha sido recibido y guardado!");
      }

      router.push('/lista');
    } else {
      // Fallback por si cambia la respuesta
      error.value = 'Login correcto, pero Odoo no envió el token esperado.';
    }

  } catch (e) {
    console.error("Error Login:", e);
    // Mostramos el mensaje limpio
    error.value = e.message || '❌ Error: Usuario o contraseña incorrectos en Odoo';
  } finally {
    isLoading.value = false;
  }
};
</script>

<style scoped>
.login-container {
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: #141414;
  font-family: 'Segoe UI', sans-serif;
  background-image: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url('https://assets.nflxext.com/ffe/siteui/vlv3/f841d4c7-10e1-40af-bcae-07a3f8dc141a/f6d7434e-d6de-4185-a6d4-c77a2d08737b/US-en-20220502-popsignuptwoweeks-perspective_alpha_website_medium.jpg');
  background-size: cover;
}

.login-card {
  background: rgba(0, 0, 0, 0.75);
  padding: 50px;
  border-radius: 8px;
  width: 100%;
  max-width: 400px;
  text-align: center;
  color: white;
}

h1 {
  color: #E50914;
  font-size: 2.5rem;
  margin-bottom: 10px;
  font-weight: bold;
}

.form-group {
  margin-bottom: 20px;
  text-align: left;
}

label {
  display: block;
  font-size: 0.9rem;
  margin-bottom: 5px;
  color: #8c8c8c;
}

input {
  width: 100%;
  padding: 12px;
  border-radius: 4px;
  border: none;
  background: #333;
  color: white;
  box-sizing: border-box;
}

input:focus {
  background: #444;
  outline: none;
  border-bottom: 2px solid #E50914;
}

.login-btn {
  width: 100%;
  padding: 12px;
  background: #E50914;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  font-weight: bold;
  cursor: pointer;
  margin-top: 15px;
}

.login-btn:hover {
  background: #f40612;
}

.login-btn:disabled {
  background: #555;
  cursor: wait;
}

.error-box {
  background: #e87c03;
  padding: 10px;
  border-radius: 4px;
  margin-top: 20px;
  text-align: left;
  font-size: 0.9rem;
}
</style>