<template>
  <div class="profile-page h-full">
    <header class="profile-header fade-in">
      <div class="header-left">
        <h1 class="page-title">Profil & Pengaturan</h1>
        <p class="page-subtitle">Kelola identitas digital dan preferensi aplikasi Anda.</p>
      </div>
      <div class="header-right">
        <span class="premium-badge glass">
          <i class="fa-solid fa-gem badge-icon"></i>
          PLATINUM MEMBER
        </span>
      </div>
    </header>

    <div class="profile-layout">
      <!-- Side Navigation for Settings -->
      <aside class="settings-nav glass glass-card fade-in">
        <button 
          v-for="item in menuItems" 
          :key="item.id" 
          class="nav-link" 
          :class="{ active: activeSection === item.id }"
          @click="activeSection = item.id"
        >
          <i :class="['nav-icon', item.icon]"></i>
          <span class="nav-label">{{ item.label }}</span>
        </button>
      </aside>

      <!-- Main Settings Content -->
      <div class="settings-content glass glass-card scale-in">
        <!-- Account Section -->
        <section v-if="activeSection === 'account'" class="settings-section">
          <div class="section-header">
            <div class="avatar-large-wrapper">
              <div class="avatar-large glass">
                <span v-if="!userProfile.avatar">U</span>
                <img v-else :src="userProfile.avatar" alt="Avatar" />
                <div class="avatar-edit-overlay">
                  <i class="fa-solid fa-camera"></i>
                </div>
              </div>
            </div>
            <div class="section-title-group">
              <h2 class="section-title">Informasi Akun</h2>
              <p class="section-desc">Detail identitas Anda yang terhubung dengan layanan Wallect.</p>
            </div>
          </div>

          <div class="settings-grid">
            <div class="form-field">
              <label>NAMA LENGKAP</label>
              <input v-model="userProfile.name" placeholder="Nama Anda" />
            </div>
            <div class="form-field">
              <label>ALAMAT EMAIL</label>
              <input v-model="userProfile.email" placeholder="email@contoh.com" disabled />
            </div>
            <div class="form-field span-2">
              <label>BIO SINGKAT</label>
              <textarea v-model="userProfile.bio" placeholder="Tuliskan sesuatu tentang perjalanan finansialmu..."></textarea>
            </div>
          </div>
          <div class="section-footer">
            <button class="save-btn glass premium-glow">Simpan Perubahan</button>
          </div>
        </section>

        <!-- Preferences Section -->
        <section v-if="activeSection === 'preferences'" class="settings-section">
          <h2 class="section-title">Preferensi Aplikasi</h2>
          <p class="section-desc">Sesuaikan cara Anda berinteraksi dengan dashboard.</p>
          
          <div class="settings-grid">
            <div class="form-field">
              <label>MATA UANG UTAMA</label>
              <select v-model="settings.currency">
                <option value="IDR">IDR - Rupiah Indonesia</option>
                <option value="USD">USD - US Dollar</option>
                <option value="EUR">EUR - Euro</option>
              </select>
            </div>
            <div class="form-field">
              <label>BAHASA</label>
              <select v-model="settings.language">
                <option value="id">Bahasa Indonesia</option>
                <option value="en">English</option>
              </select>
            </div>
            <div class="toggle-field glass card-item">
              <div class="toggle-info">
                <span class="toggle-label">Mode Privasi</span>
                <span class="toggle-desc">Sembunyikan saldo di halaman utama secara default.</span>
              </div>
              <div class="toggle-switch">
                <input type="checkbox" v-model="settings.privacyMode" id="privacy-toggle" />
                <label for="privacy-toggle"></label>
              </div>
            </div>
          </div>
        </section>

        <!-- Security Section -->
        <section v-if="activeSection === 'security'" class="settings-section">
          <h2 class="section-title">Keamanan & Akses</h2>
          <p class="section-desc">Lindungi akun Anda dengan fitur keamanan tingkat lanjut.</p>

          <div class="security-list">
            <div class="security-item glass">
              <div class="item-icon"><i class="fa-solid fa-lock"></i></div>
              <div class="item-info">
                <span class="item-title">Kata Sandi</span>
                <span class="item-meta">Terakhir diubah 2 bulan lalu</span>
              </div>
              <button class="action-btn-sm glass">Ubah</button>
            </div>
            <div class="security-item glass">
              <div class="item-icon"><i class="fa-solid fa-mobile-screen-button"></i></div>
              <div class="item-info">
                <span class="item-title">Autentikasi Dua Faktor (2FA)</span>
                <span class="item-meta">Belum diaktifkan</span>
              </div>
              <button class="action-btn-sm glass">Aktifkan</button>
            </div>
            <div class="security-item glass">
              <div class="item-icon"><i class="fa-solid fa-clock-rotate-left"></i></div>
              <div class="item-info">
                <span class="item-title">Sesi Aktif</span>
                <span class="item-meta">1 perangkat sedang login</span>
              </div>
              <button class="action-btn-sm glass">Lihat Semua</button>
            </div>
          </div>
        </section>
      </div>
    </div>
  </div>
</template>

<script setup>
const activeSection = ref('account')

const menuItems = [
  { id: 'account', label: 'Akun Saya', icon: 'fa-solid fa-user-large' },
  { id: 'preferences', label: 'Preferensi', icon: 'fa-solid fa-gear' },
  { id: 'security', label: 'Keamanan', icon: 'fa-solid fa-shield-halved' },
  { id: 'notifications', label: 'Notifikasi', icon: 'fa-solid fa-bell' },
  { id: 'billing', label: 'Berlangganan', icon: 'fa-solid fa-credit-card' },
]

const userProfile = ref({
  name: 'User Premium',
  email: 'premium.user@wallect.io',
  avatar: null,
  bio: 'Mengelola keuangan dengan lebih cerdas bersama Wallect Platinum.'
})

const settings = ref({
  currency: 'IDR',
  language: 'id',
  privacyMode: false
})
</script>

<style scoped>
.profile-page {
  display: flex;
  flex-direction: column;
  gap: 32px;
}

.profile-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.page-title {
  font-size: 32px;
  font-weight: 900;
  margin-bottom: 8px;
}

.page-subtitle {
  color: var(--text-secondary);
}

.premium-badge {
  padding: 10px 20px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 900;
  letter-spacing: 2px;
  color: var(--accent);
  display: flex;
  align-items: center;
  gap: 10px;
  border-color: rgba(168, 218, 220, 0.3) !important;
}

.profile-layout {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 32px;
  flex: 1;
}

.settings-nav {
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  height: fit-content;
}

.nav-link {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 14px 20px;
  border-radius: 16px;
  border: none;
  background: transparent;
  color: var(--text-secondary);
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s;
  text-align: left;
}

.nav-link:hover {
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
}

.nav-link.active {
  background: rgba(168, 218, 220, 0.1);
  color: var(--accent);
}

.settings-content {
  padding: 48px;
}

.settings-section {
  display: flex;
  flex-direction: column;
  gap: 32px;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 32px;
  margin-bottom: 8px;
}

.avatar-large-wrapper {
  position: relative;
}

.avatar-large {
  width: 100px;
  height: 100px;
  border-radius: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  font-weight: 800;
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.avatar-edit-overlay {
  position: absolute;
  bottom: 0px;
  right: 0px;
  width: 32px;
  height: 32px;
  background: var(--accent);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  cursor: pointer;
}

.section-title {
  font-size: 24px;
  font-weight: 900;
  margin-bottom: 4px;
}

.section-desc {
  color: var(--text-secondary);
  font-size: 14px;
}

.settings-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-field.span-2 {
  grid-column: span 2;
}

.form-field label {
  font-size: 10px;
  font-weight: 800;
  color: var(--text-secondary);
  letter-spacing: 1.5px;
}

.form-field input, .form-field select, .form-field textarea {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 16px 20px;
  border-radius: 16px;
  color: #fff;
  font-size: 14px;
}

.form-field textarea {
  height: 100px;
  resize: none;
}

.save-btn {
  padding: 14px 32px;
  border-radius: 16px;
  background: #fff !important;
  color: #000 !important;
  font-weight: 900;
  font-size: 14px;
}

/* Security Styles */
.security-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.security-item {
  display: flex;
  align-items: center;
  padding: 24px 32px;
  border-radius: 20px;
  gap: 24px;
}

.item-icon {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.05);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
}

.item-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.item-title {
  font-weight: 800;
}

.item-meta {
  font-size: 12px;
  color: var(--text-secondary);
}

.action-btn-sm {
  padding: 8px 16px;
  border-radius: 10px;
  font-size: 12px;
  font-weight: 700;
}

/* Toggle Switch Styles */
.toggle-field {
  grid-column: span 2;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 32px;
  border-radius: 24px;
}

.toggle-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.toggle-label {
  font-weight: 800;
}

.toggle-desc {
  font-size: 12px;
  color: var(--text-secondary);
}

.toggle-switch {
  position: relative;
  width: 50px;
  height: 26px;
}

.toggle-switch input { opacity: 0; width: 0; height: 0; }

.toggle-switch label {
  position: absolute;
  cursor: pointer;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: rgba(255, 255, 255, 0.1);
  transition: .4s;
  border-radius: 34px;
}

.toggle-switch label:before {
  position: absolute;
  content: "";
  height: 18px; width: 18px;
  left: 4px; bottom: 4px;
  background-color: #fff;
  transition: .4s;
  border-radius: 50%;
}

.toggle-switch input:checked + label { background-color: var(--accent); }
.toggle-switch input:checked + label:before { transform: translateX(24px); }
</style>
