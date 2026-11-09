<template>
  <div class="maintenance-page-container">
    <div class="glass-orb-bg"></div>
    
    <div class="maintenance-card glass-card fade-in">
      <MaintenanceContent />
    </div>

    <!-- Decorative Elements -->
    <div class="decor-orb d-1"></div>
    <div class="decor-orb d-2"></div>
  </div>
</template>

<script setup>
definePageMeta({
  layout: false
})
</script>

<style scoped>
.maintenance-page-container {
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

.maintenance-card {
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

.fade-in {
  animation: fadeIn 0.8s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
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
  background: #457b9d;
}

.d-2 {
  bottom: -100px;
  right: -100px;
  width: 400px;
  height: 400px;
  background: #a8dadc;
}
</style>
