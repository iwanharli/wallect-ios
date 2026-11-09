<template>
  <div class="maintenance-content">
    <div class="mascot-wrapper">
      <div class="robot-polisher">
        <div class="robot-head">
          <div class="eye-glow"></div>
        </div>
        <div class="robot-body">
          <div class="logo-box">W</div>
        </div>
        <div class="arm-left"></div>
        <div class="arm-right"></div>
        <div class="sparkles">
          <div class="spark s1"></div>
          <div class="spark s2"></div>
          <div class="spark s3"></div>
        </div>
      </div>
    </div>

    <div class="text-section">
      <h1 class="maintenance-title">Berhenti Sejenak</h1>
      <h2 class="maintenance-subtitle">SEDANG MEMOLES PLATINUM</h2>
      <p class="maintenance-description">
        Kami sedang meningkatkan sistem kemurnian finansial Anda. 
        Brankas akan segera dibuka kembali dengan fitur yang lebih elegan.
      </p>

      <div class="status-indicator">
        <div class="pulse-dot"></div>
        <span>Sistem Sedang Diperbarui</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.maintenance-content {
  text-align: center;
  max-width: 500px;
  margin: 0 auto;
}

.mascot-wrapper {
  margin-bottom: 40px;
  display: flex;
  justify-content: center;
}

/* Cute Robot CSS Art */
.robot-polisher {
  width: 140px;
  height: 160px;
  position: relative;
  animation: robotFloat 3s infinite ease-in-out;
}

.robot-head {
  width: 50px;
  height: 40px;
  background: linear-gradient(135deg, #a8dadc, #457b9d);
  border-radius: 12px;
  margin: 0 auto 5px;
  position: relative;
  border: 2px solid rgba(255,255,255,0.2);
}

.eye-glow {
  width: 30px;
  height: 8px;
  background: #fff;
  border-radius: 4px;
  position: absolute;
  top: 15px;
  left: 10px;
  box-shadow: 0 0 10px #fff;
}

.robot-body {
  width: 70px;
  height: 60px;
  background: linear-gradient(135deg, #457b9d, #1d3557);
  border-radius: 15px;
  margin: 0 auto;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid rgba(255,255,255,0.2);
}

.logo-box {
  font-weight: 800;
  font-size: 24px;
  color: #fff;
}

.arm-left, .arm-right {
  width: 40px;
  height: 6px;
  background: #a8dadc;
  position: absolute;
  top: 60px;
  border-radius: 3px;
}

.arm-left { left: 0; transform: rotate(-30deg); animation: armMoveL 1s infinite alternate; }
.arm-right { right: 0; transform: rotate(30deg); animation: armMoveR 1s infinite alternate; }

.sparkles {
  position: absolute;
  top: 30px;
  right: -20px;
}

.spark {
  position: absolute;
  width: 8px;
  height: 8px;
  background: #fff;
  clip-path: polygon(50% 0%, 61% 35%, 98% 35%, 68% 57%, 79% 91%, 50% 70%, 21% 91%, 32% 57%, 2% 35%, 39% 35%);
  animation: sparkFade 1.5s infinite;
}

.s1 { top: 0; left: 0; animation-delay: 0s; }
.s2 { top: 20px; left: 15px; animation-delay: 0.5s; }
.s3 { top: -10px; left: 25px; animation-delay: 1s; }

/* Content Styles */
.maintenance-title {
  font-size: 32px;
  font-weight: 800;
  color: #fff;
  margin-bottom: 8px;
}

.maintenance-subtitle {
  font-size: 11px;
  font-weight: 700;
  color: #a8dadc;
  letter-spacing: 4px;
  margin-bottom: 24px;
  text-transform: uppercase;
}

.maintenance-description {
  font-size: 14px;
  line-height: 1.6;
  color: rgba(255, 255, 255, 0.4);
  margin-bottom: 40px;
  padding: 0 20px;
}

.status-indicator {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  background: rgba(168, 218, 220, 0.05);
  padding: 12px 24px;
  border-radius: 40px;
  font-size: 12px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.6);
  border: 1px solid rgba(168, 218, 220, 0.1);
}

.pulse-dot {
  width: 8px;
  height: 8px;
  background: #a8dadc;
  border-radius: 50%;
  animation: pulse 1.5s infinite;
}

/* Animations */
@keyframes robotFloat {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-15px); }
}

@keyframes armMoveL { from { transform: rotate(-30deg); } to { transform: rotate(-50deg); } }
@keyframes armMoveR { from { transform: rotate(30deg); } to { transform: rotate(50deg); } }

@keyframes sparkFade {
  0%, 100% { opacity: 0; transform: scale(0.5); }
  50% { opacity: 1; transform: scale(1.2); }
}

@keyframes pulse {
  0% { transform: scale(1); box-shadow: 0 0 0 0 rgba(168, 218, 220, 0.4); }
  70% { transform: scale(1.1); box-shadow: 0 0 0 10px rgba(168, 218, 220, 0); }
  100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(168, 218, 220, 0); }
}
</style>
