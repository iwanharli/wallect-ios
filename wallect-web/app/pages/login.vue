<template>
  <div class="login-wrapper glass-card fade-in">
    <!-- Left Section: Visual Branding -->
    <div class="login-visual">
      <div class="visual-content">
        <div class="logo-box-large">
          <div class="logo-orb ripple">W</div>
          <div class="logo-rings"></div>
          <div class="logo-glow"></div>
        </div>
        <div class="brand-info">
          <h1 class="brand-title-large">WALLECT</h1>
          <div class="brand-divider"></div>
          <p class="brand-tagline">FINANCIAL PURITY SYSTEM</p>
          <div class="brand-description">
            Experience the next generation of personal wealth management. 
            Secure, intelligent, and remarkably elegant.
          </div>
        </div>
        
        <!-- Subtle Decorative Elements -->
        <div class="background-accents">
          <div class="accent-line l1"></div>
          <div class="accent-line l2"></div>
        </div>
      </div>
    </div>

    <!-- Right Section: Auth Content -->
    <div class="login-content">
      <header class="login-header">
        <h2 class="auth-title">Authentication Required</h2>
        <p class="auth-subtitle">Choose your preferred login method</p>
      </header>

      <!-- Primary Methods: Google & QR -->
      <div class="primary-auth-methods">
        <div class="google-login-container">
          <!-- Real Google Button (Hidden/Ghost) -->
          <div id="googleSigninButton" class="google-ghost-overlay"></div>
          
          <button class="google-btn premium-glow">
            <img src="https://www.google.com/favicon.ico" alt="GP" width="18" height="18" />
            <span>CONTINUE WITH GOOGLE</span>
          </button>
        </div>

        <div class="qr-protocol-highlight">
          <div v-if="!qrId" class="qr-placeholder-premium" @click="generateQr">
            <div class="qr-visual-indicator">
              <div class="scanner-line"></div>
              <i class="fa-solid fa-qrcode"></i>
            </div>
            <div class="qr-text-stack">
              <span class="qr-label">SYNC AUTHENTICATOR</span>
              <span class="qr-subtext">Secure Mobile Login</span>
            </div>
            <div class="qr-arrow">→</div>
          </div>
          
          <div v-else class="qr-card-premium glass-card fade-in">
            <div class="qr-main-content">
              <div class="qr-frame">
                <ClientOnly>
                  <qrcode-vue :value="qrId" :size="140" level="H" render-as="svg" class="qr-code" />
                </ClientOnly>
              </div>
              <div class="qr-info-side">
                <p class="qr-hint-text">Pindai dengan aplikasi Wallect</p>
                <button class="qr-action-btn" @click="generateQr">
                  <i class="fa-solid fa-rotate-right"></i>
                  <span>Segarkan Kode</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="auth-toggle-section">
        <div class="divider">
          <span class="divider-text">ATAU</span>
        </div>
        
        <button v-if="!showEmailModal" class="toggle-email-link" @click="showEmailModal = true">
          Masuk dengan Email & Kata Sandi
        </button>
      </div>
    </div>

    <!-- Elegant Login Modal -->
    <Teleport to="body">
      <transition name="modal-fade">
        <div v-if="showEmailModal" class="auth-modal-overlay" @click.self="showEmailModal = false">
          <div class="auth-modal-container glass-card scale-in">
            <button class="modal-close-btn" @click="showEmailModal = false">
              <i class="fa-solid fa-xmark"></i>
            </button>
            
            <header class="modal-header">
              <div class="modal-logo">W</div>
              <h2 class="modal-title">Selamat Datang Kembali</h2>
              <p class="modal-subtitle">Masukkan detail akun Anda untuk melanjutkan</p>
            </header>

            <form class="login-form" @submit.prevent="handleLogin">
              <div class="form-field">
                <label class="field-label">ALAMAT EMAIL</label>
                <div class="input-glow-wrapper">
                  <input type="email" placeholder="contoh@wallect.com" v-model="email" />
                </div>
              </div>

              <div class="form-field">
                <label class="field-label">KATA SANDI</label>
                <div class="input-glow-wrapper">
                  <input type="password" placeholder="••••••••" v-model="password" />
                </div>
              </div>

              <div class="form-options">
                <NuxtLink to="/forgot" class="link-text">Lupa Kata Sandi?</NuxtLink>
              </div>

              <button type="submit" class="submit-btn" :disabled="isLoading">
                <span v-if="!isLoading">VERIFIKASI & MASUK</span>
                <span v-else class="pulse-loader"></span>
              </button>
            </form>

            <div class="modal-footer">
              <p>Belum punya akun? <NuxtLink to="/register" class="accent-link">Daftar Sekarang</NuxtLink></p>
            </div>
          </div>
        </div>
      </transition>
    </Teleport>
  </div>
</template>

<script setup>
definePageMeta({
  layout: 'auth'
})

import QrcodeVue from 'qrcode.vue'
const api = useWallectApi()
const auth = useAuth()

const email = ref('')
const password = ref('')
const isLoading = ref(false)
const showEmailModal = ref(false)

const qrId = ref(null)
const qrPolling = ref(null)

const generateQr = async () => {
  try {
    const res = await api.getQrGenerate()
    qrId.value = res.id
    startPolling()
  } catch (e) {
    console.error('QR Generate Error:', e)
  }
}

const startPolling = () => {
  if (qrPolling.value) clearInterval(qrPolling.value)
  qrPolling.value = setInterval(async () => {
    try {
      const res = await api.checkQrStatus(qrId.value)
      if (res.status === 'AUTHORIZED' && res.token) {
        clearInterval(qrPolling.value)
        // Fetch user data and login
        const userData = await api.getMe() // This will use the new token automatically if we save it first
        localStorage.setItem('wallect_token', res.token)
        auth.login(res.token, userData)
      } else if (res.status === 'EXPIRED') {
        clearInterval(qrPolling.value)
        qrId.value = null
      }
    } catch (e) {
      console.error('Polling Error:', e)
    }
  }, 2000)
}

onUnmounted(() => {
  if (qrPolling.value) clearInterval(qrPolling.value)
})

const handleLogin = async () => {
  if (!email.value || !password.value) return
  isLoading.value = true
  try {
    const res = await api.fetchApi('auth/login', {
      method: 'POST',
      body: { email: email.value, password: password.value }
    })
    auth.login(res.token, res.user)
  } catch (e) {
    console.error('Login Error:', e)
    alert('Login gagal. Silakan periksa email dan kata sandi Anda.')
  } finally {
    isLoading.value = false
  }
}

const handleGoogleLogin = () => {
  // We no longer rely on prompt(), the user clicks the ghost button overlay
  console.log('Google login overlay clicked');
}

// Google Login Success Callback
const handleCredentialResponse = async (response) => {
  isLoading.value = true;
  try {
    // Decode the response (contains idToken)
    const payload = JSON.parse(atob(response.credential.split('.')[1]));
    
    const res = await api.fetchApi('auth/google', {
      method: 'POST',
      body: {
        idToken: response.credential,
        email: payload.email,
        name: payload.name || payload.given_name,
        googleId: payload.sub
      }
    });
    
    if (res.token && res.user) {
      auth.login(res.token, res.user);
    }
  } catch (e) {
    console.error('Google Auth Error:', e);
    alert('Gagal login dengan Google. Pastikan Client ID sudah dikonfigurasi.');
  } finally {
    isLoading.value = false;
  }
}

onMounted(() => {
  if (import.meta.client) {
    // Wait for GIS script to load
    const checkGis = setInterval(() => {
      if (window.google) {
        clearInterval(checkGis);
        window.google.accounts.id.initialize({
          client_id: '380422483162-qnsuv33l182p1nu2mcj0ojsmpfahfcq9.apps.googleusercontent.com',
          callback: handleCredentialResponse,
          auto_select: false
        });

        // Render the real button into our ghost overlay
        window.google.accounts.id.renderButton(
          document.getElementById('googleSigninButton'),
          { 
            theme: 'outline', 
            size: 'large',
            width: 320 // Matches our button width
          }
        );
      }
    }, 100);
  }
})
</script>

<style scoped>
.login-wrapper {
  display: flex;
  min-height: 700px;
  background: rgba(20, 24, 31, 0.6);
  backdrop-filter: blur(40px) saturate(220%);
  border: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 0 40px 100px rgba(0, 0, 0, 0.5), inset 0 1px 1px rgba(255, 255, 255, 0.05);
  overflow: hidden;
  position: relative;
  z-index: 10;
}

/* Left Visual Section */
.login-visual {
  flex: 1.2;
  position: relative;
  background: linear-gradient(165deg, #13171F 0%, #1B212C 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 80px;
  border-right: 1px solid rgba(255, 255, 255, 0.03);
  overflow: hidden;
}

.login-visual::before {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle at 10% 20%, rgba(168, 218, 220, 0.15) 0%, transparent 40%),
              radial-gradient(circle at 90% 80%, rgba(69, 123, 157, 0.1) 0%, transparent 40%);
  opacity: 0.8;
}

.visual-content {
  position: relative;
  z-index: 5;
  text-align: center;
}

.logo-box-large {
  width: 120px;
  height: 120px;
  margin: 0 auto 48px;
  position: relative;
  animation: float 10s infinite ease-in-out;
}

.logo-box-large .logo-orb {
  width: 100%;
  height: 100%;
  border-radius: 32px;
  background: linear-gradient(135deg, #fff, #a8dadc);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 800;
  font-size: 56px;
  color: #000;
  box-shadow: 0 20px 40px rgba(168, 218, 220, 0.2);
  position: relative;
  z-index: 2;
}

.logo-box-large .logo-rings {
  position: absolute;
  top: -20px;
  left: -20px;
  right: -20px;
  bottom: -20px;
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 40px;
  animation: rotate 20s linear infinite;
}

.brand-title-large {
  font-size: 56px;
  font-weight: 800;
  letter-spacing: 24px;
  margin-right: -24px;
  margin-bottom: 24px;
  background: linear-gradient(to bottom, #ffffff 0%, rgba(255, 255, 255, 0.4) 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  display: inline-block;
}

.brand-divider {
  width: 40px;
  height: 1px;
  background: rgba(255, 255, 255, 0.2);
  margin: 0 auto 24px;
}

.brand-tagline {
  font-size: 11px;
  color: var(--accent);
  letter-spacing: 8px;
  font-weight: 600;
  text-transform: uppercase;
  margin-bottom: 32px;
  opacity: 0.8;
}

.brand-description {
  max-width: 340px;
  margin: 0 auto;
  font-size: 14px;
  line-height: 1.8;
  color: rgba(255, 255, 255, 0.4);
  font-weight: 400;
  letter-spacing: 0.2px;
}

/* Right Content Section */
.login-content {
  flex: 1;
  padding: 80px 100px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  position: relative;
}

.login-header {
  margin-bottom: 56px;
}

.auth-title {
  font-size: 32px;
  font-weight: 700;
  color: #fff;
  margin-bottom: 12px;
  letter-spacing: -1px;
}

.auth-subtitle {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.4);
  font-weight: 400;
}

/* Primary Auth Methods */
.primary-auth-methods {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.google-login-container {
  position: relative;
  width: 100%;
  display: flex;
  justify-content: center;
}

.google-ghost-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 10;
  opacity: 0; /* Completely invisible ghost button */
  cursor: pointer;
  display: flex;
  justify-content: center;
  align-items: center;
  overflow: hidden;
}

:deep(.google-ghost-overlay iframe) {
  transform: scale(3); /* Make the iframe much larger to ensure the click hits it */
  transform-origin: center;
  cursor: pointer !important;
}

.google-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  background: rgba(255, 255, 255, 0.05) !important;
  color: #fff !important;
  border: 1px solid rgba(255, 255, 255, 0.1) !important;
  padding: 18px 24px !important;
  font-size: 11px !important;
  font-weight: 700 !important;
  letter-spacing: 2px !important;
  border-radius: 24px !important;
  backdrop-filter: blur(10px) !important;
  transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1) !important;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2) !important;
  width: 100%;
  pointer-events: none; /* Let the ghost overlay handle clicks */
}

.google-login-container:hover .google-btn {
  background: rgba(255, 255, 255, 0.1) !important;
  border-color: var(--accent) !important;
  transform: translateY(-2px);
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.4), 0 0 20px var(--accent-glow) !important;
}

.qr-placeholder-premium {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 28px;
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 24px;
  cursor: pointer;
  transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1);
  position: relative;
  overflow: hidden;
}

.qr-placeholder-premium:hover {
  background: rgba(255, 255, 255, 0.05);
  border-color: rgba(255, 255, 255, 0.2);
  transform: scale(1.02);
}

.qr-visual-indicator {
  width: 52px;
  height: 52px;
  background: rgba(168, 218, 220, 0.05);
  border: 1px solid rgba(168, 218, 220, 0.1);
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}

.scanner-line {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 2px;
  background: var(--accent);
  box-shadow: 0 0 10px var(--accent);
  animation: scan 2s infinite ease-in-out;
  opacity: 0.5;
}

@keyframes scan {
  0% { top: 10%; }
  50% { top: 90%; }
  100% { top: 10%; }
}

.qr-text-stack {
  flex: 1;
  margin-left: 20px;
  display: flex;
  flex-direction: column;
}

.qr-label {
  font-size: 13px;
  font-weight: 700;
  color: #fff;
  letter-spacing: 0.5px;
}

.qr-subtext {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.4);
  font-weight: 500;
}

.qr-arrow {
  font-size: 20px;
  color: rgba(255, 255, 255, 0.2);
  transition: transform 0.3s;
}

.qr-placeholder-premium:hover .qr-arrow {
  transform: translateX(5px);
  color: var(--accent);
}

/* Premium QR Card Refinement */
.qr-card-premium {
  padding: 32px;
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.05);
}

.qr-main-content {
  display: flex;
  align-items: center;
  gap: 32px;
}

.qr-frame {
  padding: 16px;
  background: #fff;
  border-radius: 20px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}

.qr-code {
  border-radius: 8px;
}

.qr-info-side {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.qr-hint-text {
  font-size: 14px;
  line-height: 1.5;
  color: rgba(255, 255, 255, 0.8);
  font-weight: 500;
}

.qr-action-btn {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #fff;
  padding: 12px 20px;
  border-radius: 14px;
  font-size: 12px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  transition: all 0.3s;
  width: fit-content;
}

.qr-action-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  border-color: var(--accent);
}

/* Toggle Link */
.auth-toggle-section {
  margin-top: 48px;
  text-align: center;
}

.toggle-email-link {
  background: transparent;
  border: none;
  color: rgba(255, 255, 255, 0.4);
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  text-decoration: underline;
  text-underline-offset: 4px;
}

.toggle-email-link:hover {
  color: var(--accent);
}

/* Modal Styling */
.auth-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.85);
  backdrop-filter: blur(20px);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.auth-modal-container {
  width: 100%;
  max-width: 480px;
  background: #0a0a0a;
  border-radius: 32px;
  padding: 48px;
  position: relative;
  border: 1px solid rgba(255, 255, 255, 0.08);
  box-shadow: 0 50px 100px rgba(0, 0, 0, 0.9);
}

.modal-close-btn {
  position: absolute;
  top: 24px;
  right: 24px;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  color: #fff;
  font-size: 24px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.modal-close-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: rotate(90deg);
}

.modal-header {
  text-align: center;
  margin-bottom: 40px;
}

.modal-logo {
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, var(--accent), var(--primary));
  border-radius: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  font-weight: 800;
  color: #000;
  margin: 0 auto 24px;
}

.modal-title {
  font-size: 28px;
  font-weight: 700;
  color: #fff;
  margin-bottom: 8px;
}

.modal-subtitle {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.4);
}

/* Form Styling Refined */
.login-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.field-label {
  display: block;
  font-size: 10px;
  font-weight: 800;
  color: rgba(255, 255, 255, 0.3);
  margin-bottom: 12px;
  letter-spacing: 2px;
  text-transform: uppercase;
}

.input-glow-wrapper input {
  width: 100%;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 18px;
  padding: 20px 24px;
  color: #fff;
  font-size: 15px;
  font-weight: 500;
  transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
  letter-spacing: 0.2px;
}

.input-glow-wrapper input:focus {
  border-color: var(--accent);
  background: rgba(255, 255, 255, 0.06);
  box-shadow: 0 0 30px rgba(168, 218, 220, 0.1), inset 0 0 10px rgba(168, 218, 220, 0.05);
  outline: none;
  transform: translateY(-1px);
}

.form-options {
  text-align: right;
}

.link-text {
  font-size: 13px;
  color: var(--accent);
  text-decoration: none;
}

.submit-btn {
  background: #fff;
  color: #000;
  border: none;
  border-radius: 20px;
  padding: 20px;
  font-weight: 800;
  font-size: 13px;
  letter-spacing: 1.5px;
  cursor: pointer;
  transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1);
  margin-top: 10px;
}

.submit-btn:hover:not(:disabled) {
  background: var(--accent);
  transform: translateY(-3px);
  box-shadow: 0 15px 40px rgba(168, 218, 220, 0.4);
}

.modal-footer {
  margin-top: 32px;
  text-align: center;
  font-size: 14px;
  color: rgba(255, 255, 255, 0.4);
}

.accent-link {
  color: var(--accent);
  text-decoration: none;
  font-weight: 600;
}

/* Animations & Transitions */
.modal-fade-enter-active, .modal-fade-leave-active {
  transition: opacity 0.4s cubic-bezier(0.23, 1, 0.32, 1);
}
.modal-fade-enter-from, .modal-fade-leave-to {
  opacity: 0;
}

.scale-in {
  animation: scaleIn 0.5s cubic-bezier(0.23, 1, 0.32, 1) forwards;
}

@keyframes scaleIn {
  from { transform: scale(0.9) translateY(20px); opacity: 0; }
  to { transform: scale(1) translateY(0); opacity: 1; }
}

/* Transitions & Dividers */
.divider {
  margin: 40px 0;
  position: relative;
}

.divider::before {
  content: "";
  position: absolute;
  top: 50%;
  left: 0;
  width: 100%;
  height: 1px;
  background: rgba(255, 255, 255, 0.03);
}

.divider-text {
  background: #080808;
  padding: 0 20px;
  font-size: 10px;
  color: rgba(255, 255, 255, 0.2);
  font-weight: 600;
  letter-spacing: 2px;
  position: relative;
  z-index: 2;
  left: 50%;
  transform: translateX(-50%);
}

/* Base Keyframes */
@keyframes rotate { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
/* Accent Lines */
.background-accents {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  overflow: hidden;
}

.accent-line {
  position: absolute;
  background: linear-gradient(90deg, transparent, var(--accent), transparent);
  height: 1px;
  width: 100%;
  opacity: 0.1;
}

.l1 { top: 20%; animation: pulse-acc 8s infinite alternate; }
.l2 { bottom: 20%; animation: pulse-acc 12s infinite alternate-reverse; }

@keyframes pulse-acc {
  from { opacity: 0.05; transform: translateX(-10%); }
  to { opacity: 0.15; transform: translateX(10%); }
}

.ripple {
  position: relative;
}

.ripple::after {
  content: "";
  position: absolute;
  top: 50%;
  left: 50%;
  width: 100%;
  height: 100%;
  border: 1px solid var(--accent);
  border-radius: inherit;
  transform: translate(-50%, -50%) scale(1);
  opacity: 0;
  animation: ripple-effect 4s infinite;
}

@keyframes ripple-effect {
  0% { transform: translate(-50%, -50%) scale(1); opacity: 0.5; }
  100% { transform: translate(-50%, -50%) scale(1.5); opacity: 0; }
}

@keyframes float {
  0%, 100% { transform: translateY(0) scale(1); }
  50% { transform: translateY(-15px) scale(1.02); }
}

/* Responsiveness */
@media (max-width: 968px) {
  .login-wrapper {
    flex-direction: column;
  }
  
  .login-visual {
    padding: 60px 40px;
    border-right: none;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  }
  
  .login-content {
    padding: 60px 40px;
  }
}

@media (max-width: 480px) {
  .login-visual {
    display: none;
  }
  
  .login-content {
    padding: 40px 24px;
  }
  
  .auth-modal-container {
    padding: 32px 24px;
    border-radius: 24px;
  }
}
</style>
