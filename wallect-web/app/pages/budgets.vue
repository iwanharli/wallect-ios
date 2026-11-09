<template>
  <div class="budgets-page">
    <header class="page-header fade-in">
      <div class="header-content">
        <h1 class="page-title">Anggaran & Perencanaan</h1>
        <p class="page-subtitle">Atur batas pengeluaran untuk setiap kategori agar keuanganmu tetap terjaga.</p>
      </div>
      <button class="add-budget-btn glass-card premium-glow">
        <span class="btn-icon">+</span>
        <span>Anggaran Baru</span>
      </button>
    </header>

    <div class="budgets-grid">
      <div v-for="budget in budgets" :key="budget.id" class="budget-card glass glass-card fade-in">
        <div class="budget-header">
          <div class="budget-icon glass">{{ budget.icon }}</div>
          <div class="budget-info">
            <h3 class="budget-name">{{ budget.category }}</h3>
            <span class="budget-period">BULANAN</span>
          </div>
        </div>
        
        <div class="budget-status">
          <div class="status-amounts">
            <span class="spent">{{ formatCurrency(budget.spent) }}</span>
            <span class="limit">dari {{ formatCurrency(budget.limit) }}</span>
          </div>
          <div class="progress-track glass">
            <div 
              class="progress-fill" 
              :style="{ width: (budget.spent / budget.limit * 100) + '%' }"
              :class="{ over: budget.spent > budget.limit }"
            ></div>
          </div>
          <div class="remaining-text">
            Sisa: {{ formatCurrency(budget.limit - budget.spent) }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
const formatCurrency = (amount) => {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    maximumFractionDigits: 0
  }).format(amount)
}

const budgets = ref([
  { id: 1, category: 'Food & Beverage', spent: 1200000, limit: 3000000, icon: '🍔' },
  { id: 2, category: 'Transportasi', spent: 450000, limit: 1000000, icon: '🚗' },
  { id: 3, category: 'Hiburan', spent: 800000, limit: 1500000, icon: '🎬' },
  { id: 4, category: 'Belanja', spent: 2500000, limit: 2000000, icon: '🛍️' },
])
</script>

<style scoped>
.budgets-page {
  display: flex;
  flex-direction: column;
  gap: 40px;
}

.page-header {
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

.add-budget-btn {
  display: flex;
  align-items: center;
  gap: 12px;
  background: rgba(168, 218, 220, 0.1) !important;
  color: var(--accent) !important;
  padding: 14px 24px !important;
  border: 1px solid rgba(168, 218, 220, 0.2) !important;
  border-radius: 20px !important;
  font-weight: 800;
  cursor: pointer;
}

.budgets-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 24px;
}

.budget-card {
  padding: 32px;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.budget-header {
  display: flex;
  align-items: center;
  gap: 16px;
}

.budget-icon {
  width: 48px;
  height: 48px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.budget-name {
  font-size: 16px;
  font-weight: 800;
  margin-bottom: 2px;
}

.budget-period {
  font-size: 10px;
  font-weight: 900;
  color: var(--text-secondary);
  letter-spacing: 1px;
}

.budget-status {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.status-amounts {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
}

.spent {
  font-size: 20px;
  font-weight: 900;
}

.limit {
  font-size: 12px;
  color: var(--text-secondary);
  font-weight: 700;
}

.progress-track {
  height: 10px;
  border-radius: 5px;
  overflow: hidden;
  position: relative;
}

.progress-fill {
  height: 100%;
  background: var(--accent);
  box-shadow: 0 0 10px var(--accent);
  border-radius: 5px;
  transition: width 1s ease-out;
}

.progress-fill.over {
  background: var(--expense);
  box-shadow: 0 0 10px var(--expense);
}

.remaining-text {
  font-size: 12px;
  font-weight: 700;
  color: var(--text-secondary);
  text-align: right;
}
</style>
