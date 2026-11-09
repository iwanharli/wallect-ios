<template>
  <div class="app-container">
    <!-- Background Visuals -->
    <div class="bg-visual-layer">
      <div class="mesh-orb orb-1"></div>
      <div class="mesh-orb orb-2"></div>
      <div class="mesh-orb orb-3"></div>
    </div>

    <!-- Premium Sidebar -->
    <aside class="sidebar">
      <div class="logo-section">
        <img src="/logo.png" class="brand-logo-img" alt="Wallect" />
      </div>
      
      <nav class="nav-menu">
        <NuxtLink to="/dashboard" class="nav-item nav-dashboard glass" active-class="active" title="Dashboard">
          <i class="fa-solid fa-chart-line"></i>
        </NuxtLink>
        <NuxtLink to="/wallets" class="nav-item nav-wallets glass" active-class="active" title="Wallets">
          <i class="fa-solid fa-wallet"></i>
        </NuxtLink>
        <NuxtLink to="/transactions" class="nav-item nav-transactions glass" active-class="active" title="Transactions">
          <i class="fa-solid fa-receipt"></i>
        </NuxtLink>
        <NuxtLink to="/budgets" class="nav-item nav-budgets glass" active-class="active" title="Budgets">
          <i class="fa-solid fa-chart-pie"></i>
        </NuxtLink>
        <NuxtLink to="/debts" class="nav-item nav-debts glass" active-class="active" title="Debts">
          <i class="fa-solid fa-clock-rotate-left"></i>
        </NuxtLink>
      </nav>
      
    </aside>

    <!-- Main Content Area -->
    <main class="main-content">
      <div class="content-main-area">
        <header class="top-header">
          <div class="header-search glass">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text" placeholder="Cari transaksi..." />
          </div>
          <div class="header-right-actions">
            <NuxtLink to="/profile" class="header-profile-link" title="Profile">
              <div class="h-avatar glass">
                <img v-if="auth.user.value?.avatar" :src="auth.user.value.avatar" class="avatar-img" alt="Profile" />
                <span v-else>{{ auth.user.value?.name?.charAt(0) || 'U' }}</span>
              </div>
            </NuxtLink>
            <button class="header-logout-btn" @click="handleLogout" title="Log Out">
              <i class="fa-solid fa-right-from-bracket"></i>
            </button>
          </div>
        </header>
        
        <div class="content-wrapper">
          <slot />
        </div>
      </div>

      <!-- Global Activity Feed (Transactions) -->
      <aside class="activity-feed-column glass" :class="{ 'minimized': isMinimized }">
        <button class="minimize-toggle glass" @click="isMinimized = !isMinimized" :title="isMinimized ? 'Expand' : 'Minimize'">
          <i class="fa-solid" :class="isMinimized ? 'fa-chevron-left' : 'fa-chevron-right'"></i>
        </button>
        
        <div class="feed-header">
          <div class="header-left-v3">
            <h2 class="feed-title-v3">Transactions</h2>
            <div class="date-navigator-v3">
              <button class="date-nav-btn" @click="prevDay"><i class="fa-solid fa-chevron-left"></i></button>
              <p class="feed-subtitle-v3">{{ displayDate }}</p>
              <button class="date-nav-btn" @click="nextDay"><i class="fa-solid fa-chevron-right"></i></button>
            </div>
          </div>
          <div class="user-chip">
            <i class="fa-solid fa-receipt"></i>
          </div>
        </div>

        <div class="feed-list">
          <div 
            v-for="tx in dailyTransactions" 
            :key="tx.id" 
            class="feed-item-tx"
          >
            <div class="tx-icon-v3" :class="tx.isExpense ? 'expense' : 'income'">
              <i :class="tx.icon"></i>
            </div>
            <div class="item-main">
              <div class="item-top-row">
                <strong>{{ tx.title }}</strong>
              </div>
              <span>{{ tx.category }} • {{ tx.time }}</span>
            </div>
            <div class="item-amount-v3" :class="tx.isExpense ? 'expense' : 'income'">
              {{ tx.isExpense ? '-' : '+' }} {{ formatCurrency(tx.amount) }}
            </div>
          </div>
        </div>

        <button class="fab-btn neon-glow" @click="showAddTransaction = true">
          <i class="fa-solid fa-plus"></i>
          <span class="fab-text">Tambah Transaksi</span>
        </button>
      </aside>

      <!-- Global Add Transaction Modal -->
      <AddTransactionModal 
        :is-open="showAddTransaction" 
        @close="showAddTransaction = false"
        @success="handleTransactionSuccess"
      />
    </main>
  </div>
</template>

<script setup>
import Swal from 'sweetalert2'

const api = useWallectApi()
const route = useRoute()
const auth = useAuth()
const showAddTransaction = ref(false)
const isMinimized = ref(false)
const dailyTransactions = ref([])
const activeDate = ref(new Date())

const displayDate = computed(() => {
  const today = new Date()
  const isToday = activeDate.value.toDateString() === today.toDateString()
  const dateStr = activeDate.value.toLocaleDateString('en-US', { day: 'numeric', month: 'short' })
  return isToday ? `TODAY, ${dateStr}` : dateStr
})

const prevDay = () => {
  const d = new Date(activeDate.value)
  d.setDate(d.getDate() - 1)
  activeDate.value = d
}

const nextDay = () => {
  const d = new Date(activeDate.value)
  d.setDate(d.getDate() + 1)
  activeDate.value = d
}

const formatCurrency = (amount) => {
  return 'Rp. ' + (amount || 0).toLocaleString('id-ID')
}

const handleLogout = () => {
  Swal.fire({
    title: 'Keluar dari Wallect?',
    text: 'Sesi Anda akan berakhir dan Anda harus masuk kembali untuk mengelola finansial.',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#E63946',
    cancelButtonColor: '#222',
    confirmButtonText: 'Ya, Keluar Sekarang',
    cancelButtonText: 'Batal',
    background: '#1A1A1A',
    color: '#fff',
    backdrop: `rgba(0,0,0,0.8)`,
    customClass: {
      popup: 'swal-premium-popup',
      title: 'swal-premium-title',
      confirmButton: 'swal-premium-confirm'
    }
  }).then((result) => {
    if (result.isConfirmed) {
      auth.logout()
    }
  })
}

const handleTransactionSuccess = () => {
  refreshNuxtData()
}

onMounted(async () => {
  // Mock data for global sidebar
  dailyTransactions.value = [
    { id: 1, title: 'Gaji Bulanan', amount: 15000000, category: 'Income', isExpense: false, time: '09:00 am', icon: 'fa-solid fa-hand-holding-dollar' },
    { id: 2, title: 'Makan Siang Bakmie', amount: 45000, category: 'Food', isExpense: true, time: '12:30 pm', icon: 'fa-solid fa-utensils' },
    { id: 3, title: 'Token Listrik', amount: 200000, category: 'Utility', isExpense: true, time: '02:00 pm', icon: 'fa-solid fa-bolt' }
  ]
})
</script>

<style scoped>
.app-container {
  display: flex;
  min-height: 100vh;
  background: var(--bg-deep);
}

/* Sidebar Styling */
.sidebar {
  width: 90px;
  border-radius: 0;
  display: flex;
  flex-direction: column;
  padding: 30px 0;
  position: fixed;
  height: 100vh;
  z-index: 10;
  background: #000;
  border-right: 1px solid var(--glass-border);
}

.logo-section {
  display: flex;
  justify-content: center;
  margin-bottom: 50px;
}

.brand-logo-img {
  width: 54px;
  height: 54px;
  object-fit: contain;
  border-radius: 18px;
  filter: drop-shadow(0 0 15px var(--accent-glow));
  transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.brand-logo-img:hover {
  transform: scale(1.15) rotate(5deg);
}

/* Navigation Menu */
.nav-menu {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
  flex: 1;
}

.nav-item {
  width: 54px;
  height: 54px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 18px;
  transition: all 0.4s cubic-bezier(0.23, 1, 0.32, 1);
  text-decoration: none;
  color: var(--text-secondary);
  border: 1px solid transparent;
  font-size: 20px;
}

/* Color Identities */
.nav-dashboard { --nav-color: #4CC9F0; --nav-glow: rgba(76, 201, 240, 0.2); }
.nav-wallets   { --nav-color: #9D4EDD; --nav-glow: rgba(157, 78, 221, 0.2); }
.nav-transactions { --nav-color: #DFFF00; --nav-glow: rgba(223, 255, 0, 0.2); }
.nav-budgets   { --nav-color: #FFB703; --nav-glow: rgba(255, 183, 3, 0.2); }
.nav-debts     { --nav-color: #E63946; --nav-glow: rgba(230, 57, 70, 0.2); }

.nav-item:hover {
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
  transform: scale(1.1);
}

.nav-item.active {
  background: var(--nav-glow);
  border-color: var(--nav-color);
  box-shadow: 0 0 25px var(--nav-glow);
  color: var(--nav-color);
}

/* Profile Section */
.profile-section {
  background: rgba(255, 255, 255, 0.03);
  padding: 18px;
  border-radius: 28px;
  display: flex;
  align-items: center;
  gap: 16px;
  margin-top: auto;
  border: 1px solid rgba(255, 255, 255, 0.05);
  transition: all 0.3s;
}

.profile-section:hover {
  background: rgba(255, 255, 255, 0.06);
  border-color: rgba(255, 255, 255, 0.1);
}

.avatar {
  width: 44px;
  height: 44px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.1);
  font-weight: 700;
}

.profile-info {
  display: flex;
  flex-direction: column;
}

.profile-name {
  font-weight: 700;
  font-size: 14px;
}

.profile-tag {
  font-size: 11px;
  color: var(--accent);
}

.header-right-actions {
  display: flex;
  align-items: center;
  gap: 20px;
}

.h-avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: #111;
  border: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 900;
  transition: all 0.3s;
  color: #fff;
  overflow: hidden;
}

.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.header-profile-link:hover .h-avatar {
  border-color: var(--accent);
  box-shadow: 0 0 15px var(--accent-glow);
  transform: scale(1.05);
}

.header-logout-btn {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: rgba(230, 57, 70, 0.05);
  border: 1px solid rgba(230, 57, 70, 0.15);
  color: #E63946;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s;
}

.header-logout-btn:hover {
  background: #E63946;
  color: #fff;
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(230, 57, 70, 0.3);
}

/* Main Content Area Styling */
.main-content {
  flex: 1;
  margin-left: 90px;
  display: flex;
}

.content-main-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.top-header {
  height: 100px;
  padding: 0 60px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  position: sticky;
  top: 0;
  background: rgba(22, 26, 35, 0.85);
  backdrop-filter: blur(25px);
  z-index: 5;
}

.header-search {
  width: 400px;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 20px;
  border-radius: 20px;
}

.header-search input {
  background: transparent;
  border: none;
  color: #fff;
  font-family: inherit;
  font-size: 14px;
  width: 100%;
}

.header-search input:focus {
  outline: none;
}

.add-btn {
  padding: 12px 24px;
  border-radius: 20px;
  color: var(--accent);
  font-size: 13px;
  font-weight: 800;
  cursor: pointer;
  transition: all 0.3s ease;
}

.add-btn:hover {
  background: rgba(168, 218, 220, 0.1);
  box-shadow: 0 0 15px rgba(168, 218, 220, 0.2);
}

.content-wrapper {
  padding: 20px 60px 60px;
}

.fade-in {
  animation: fadeIn 0.8s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

@media (max-width: 1024px) {
  .sidebar { width: 80px; }
  .nav-text, .logo-text, .profile-info { display: none; }
  .sidebar { padding: 40px 12px; }
  .main-content { margin-left: 80px; }
  .top-header { padding: 0 30px; }
  .content-wrapper { padding: 20px 30px; }
}
</style>
