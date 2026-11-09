<template>
  <div class="auth-layout">
    <!-- Dynamic Mesh 2.0 Background -->
    <div class="mesh-background">
      <div class="glow-sphere s-1"></div>
      <div class="glow-sphere s-2"></div>
      <div class="glow-sphere s-3"></div>
      <div class="glow-sphere s-4"></div>
      <div class="glow-sphere s-5"></div>
    </div>
    
    <!-- Grain Overlay -->
    <div class="grain-overlay"></div>
    
    <main class="auth-wrapper fade-in">
      <slot />
    </main>
    
    <footer class="auth-branding">
      <div class="brand-line"></div>
      <span class="brand-text">WALLECT PLATINUM • EST. 2026</span>
    </footer>
  </div>
</template>

<style scoped>
.auth-layout {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--bg-deep);
  position: relative;
  overflow: hidden;
  user-select: none;
}

/* Mesh 2.0 Styling */
.mesh-background {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1;
  filter: blur(140px);
  opacity: 0.5;
}

.glow-sphere {
  position: absolute;
  border-radius: 50%;
  filter: blur(40px);
  animation: organic-float 30s infinite alternate ease-in-out;
}

.s-1 { width: 600px; height: 600px; background: var(--accent); top: -200px; left: -100px; opacity: 0.4; animation-duration: 25s; }
.s-2 { width: 500px; height: 500px; background: var(--primary); bottom: -100px; right: -100px; opacity: 0.3; animation-delay: -7s; }
.s-3 { width: 400px; height: 400px; background: #FFD700; top: 10%; right: 10%; opacity: 0.15; animation-delay: -12s; }
.s-4 { width: 450px; height: 450px; background: var(--secondary); bottom: 10%; left: 10%; opacity: 0.2; animation-delay: -18s; }
.s-5 { width: 350px; height: 350px; background: #E63946; top: 50%; left: 50%; opacity: 0.08; animation-delay: -22s; }

@keyframes organic-float {
  0% { transform: translate(0, 0) scale(1) rotate(0deg); }
  33% { transform: translate(80px, -120px) scale(1.1) rotate(5deg); }
  66% { transform: translate(-100px, 60px) scale(0.9) rotate(-3deg); }
  100% { transform: translate(40px, 80px) scale(1) rotate(0deg); }
}

.grain-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 2;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3%3Cfilter id='noiseFilter'%3%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3%3C/filter%3%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3%3C/svg%3");
  opacity: 0.02;
  pointer-events: none;
}

.auth-wrapper {
  position: relative;
  z-index: 10;
  width: 100%;
  max-width: 1100px;
  padding: 40px 24px;
}

.auth-branding {
  position: absolute;
  bottom: 50px;
  z-index: 10;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
}

.brand-line {
  width: 40px;
  height: 1px;
  background: var(--accent);
  box-shadow: 0 0 10px var(--accent);
  opacity: 0.3;
}

.brand-text {
  font-size: 9px;
  letter-spacing: 4px;
  color: var(--text-secondary);
  font-weight: 800;
}
</style>
