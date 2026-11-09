<template>
  <div class="error-page-container">
    <div class="glass-orb-bg"></div>
    
    <div class="error-card glass-card fade-in">
      <div class="mascot-wrapper">
        <div class="floating-coin-container">
          <div class="silver-coin">
            <div class="coin-rim"></div>
            <div class="coin-face">
              <div class="eyes">
                <div class="eye left"></div>
                <div class="eye right"></div>
              </div>
              <div class="mouth sad"></div>
            </div>
          </div>
          <div class="coin-shadow"></div>
        </div>
      </div>

      <div class="content-section">
        <h1 class="error-code">404</h1>
        <h2 class="error-title">Bilik Rahasia Tidak Ditemukan</h2>
        <p class="error-description">
          Maaf, sepertinya brankas yang Anda cari sedang kosong atau dipindahkan. 
          Mari kita kembali ke jalur utama.
        </p>

        <NuxtLink to="/" class="return-btn premium-glow">
          <span>KEMBALI KE BERANDA</span>
        </NuxtLink>
      </div>
    </div>

    <!-- Decorative Elements -->
    <div class="decor-orb d-1"></div>
    <div class="decor-orb d-2"></div>
  </div>
</template>

<script setup>
const error = useError()

// Handle returning to homepage and clearing error
const handleError = () => clearError({ redirect: '/' })
</script>

<style scoped>
.error-page-container {
  min-height: 100vh;
  background: #050505;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Plus Jakarta Sans', sans-serif;
  overflow: hidden;
  position: relative;
  color: #fff;
}

.glass-orb-bg {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 600px;
  height: 600px;
  background: radial-gradient(circle, rgba(168, 218, 220, 0.08) 0%, transparent 70%);
  border-radius: 50%;
  filter: blur(80px);
}

.error-card {
  width: 100%;
  max-width: 500px;
  padding: 60px 40px;
  background: rgba(255, 255, 255, 0.02);
  backdrop-filter: blur(40px);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 40px;
  text-align: center;
  box-shadow: 0 40px 100px rgba(0, 0, 0, 0.6);
  z-index: 10;
}

.mascot-wrapper {
  margin-bottom: 40px;
  display: flex;
  justify-content: center;
}

/* Cute Floating Coin CSS Art */
.floating-coin-container {
  width: 140px;
  height: 140px;
  position: relative;
  animation: float 4s infinite ease-in-out;
}

.silver-coin {
  width: 120px;
  height: 120px;
  background: linear-gradient(135deg, #e0e0e0, #888);
  border-radius: 50%;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: inset 0 2px 4px rgba(255, 255, 255, 0.4), 
              inset 0 -2px 4px rgba(0, 0, 0, 0.2);
  border: 2px solid rgba(255, 255, 255, 0.2);
}

.coin-rim {
  position: absolute;
  top: 10px;
  left: 10px;
  right: 10px;
  bottom: 10px;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 50%;
}

.eyes {
  display: flex;
  gap: 12px;
  margin-top: -10px;
}

.eye {
  width: 12px;
  height: 12px;
  background: #333;
  border-radius: 50%;
  position: relative;
}

.eye::after {
  content: "";
  position: absolute;
  top: 2px;
  left: 2px;
  width: 4px;
  height: 4px;
  background: #fff;
  border-radius: 50%;
}

.mouth {
  width: 24px;
  height: 12px;
  border: 2px solid #333;
  border-top: none;
  border-radius: 0 0 12px 12px;
  margin: 12px auto 0;
}

.mouth.sad {
  border: 2px solid #333;
  border-bottom: none;
  border-radius: 12px 12px 0 0;
  margin-top: 18px;
}

.coin-shadow {
  width: 60px;
  height: 10px;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 50%;
  position: absolute;
  bottom: -40px;
  left: 50%;
  transform: translateX(-50%);
  animation: shadowPulse 4s infinite ease-in-out;
}

/* Content Styles */
.error-code {
  font-size: 80px;
  font-weight: 800;
  background: linear-gradient(to bottom, #fff, rgba(255,255,255,0.2));
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 10px;
  letter-spacing: -2px;
}

.error-title {
  font-size: 24px;
  font-weight: 700;
  color: #fff;
  margin-bottom: 16px;
}

.error-description {
  font-size: 14px;
  line-height: 1.6;
  color: rgba(255, 255, 255, 0.4);
  margin-bottom: 40px;
  padding: 0 20px;
}

.return-btn {
  display: inline-flex;
  background: #fff;
  color: #000;
  padding: 16px 32px;
  border-radius: 16px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 1px;
  text-decoration: none;
  transition: all 0.4s cubic-bezier(0.23, 1, 0.32, 1);
}

.return-btn:hover {
  background: var(--accent);
  transform: translateY(-3px);
  box-shadow: 0 20px 40px rgba(168, 218, 220, 0.2);
}

/* Decor Elements */
.decor-orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(100px);
  opacity: 0.2;
}

.d-1 {
  top: -100px;
  left: -100px;
  width: 400px;
  height: 400px;
  background: var(--accent);
}

.d-2 {
  bottom: -100px;
  right: -100px;
  width: 400px;
  height: 400px;
  background: var(--primary);
}

@keyframes float {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  50% { transform: translateY(-20px) rotate(5deg); }
}

@keyframes shadowPulse {
  0%, 100% { transform: translateX(-50%) scale(1); opacity: 0.2; }
  50% { transform: translateX(-50%) scale(1.2); opacity: 0.1; }
}

.fade-in {
  animation: fadeIn 0.8s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
