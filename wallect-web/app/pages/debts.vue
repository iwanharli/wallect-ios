<template>
  <div class="debts-page">
    <header class="page-header fade-in">
      <div class="header-content">
        <h1 class="page-title">Hutang & Piutang</h1>
        <p class="page-subtitle">Kelola dan pantau semua pinjaman yang perlu kamu lunasi atau tagih.</p>
      </div>
      <button class="add-debt-btn glass-card premium-glow">
        <span class="btn-icon">+</span>
        <span>Catat Pinjaman</span>
      </button>
    </header>

    <div class="debts-summary stats-grid">
      <div class="stat-card glass glass-card">
        <span class="card-label">TOTAL HUTANG</span>
        <div class="balance-amount expense">Rp 2.400.000</div>
        <p class="card-desc">Uang yang harus kamu bayar ke orang lain</p>
      </div>
      <div class="stat-card glass glass-card">
        <span class="card-label">TOTAL PIUTANG</span>
        <div class="balance-amount income">Rp 500.000</div>
        <p class="card-desc">Uang orang lain yang ada di kamu</p>
      </div>
    </div>

    <div class="debts-list-section glass glass-card fade-in">
      <h3 class="section-title">Daftar Pinjaman Aktif</h3>
      <div class="debts-list">
        <div v-for="debt in debts" :key="debt.id" class="debt-item glass">
          <div class="debt-main">
            <div class="debt-avatar glass">{{ debt.person[0] }}</div>
            <div class="debt-details">
              <span class="person-name">{{ debt.person }}</span>
              <span class="debt-date">Sejak {{ formatDate(debt.date) }}</span>
            </div>
          </div>
          <div class="debt-amount">
            <span :class="debt.isPayable ? 'expense' : 'income'" class="amount-val">
              {{ formatCurrency(debt.amount) }}
            </span>
            <span class="debt-type">{{ debt.isPayable ? 'Hutang' : 'Piutang' }}</span>
          </div>
          <div class="debt-actions">
            <button class="action-btn glass">Lunasi</button>
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

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('id-ID', {
    day: '2-digit',
    month: 'short',
    year: 'numeric'
  })
}

const debts = ref([
  { id: 1, person: 'Andi Pratama', amount: 1500000, date: '2026-03-15', isPayable: true },
  { id: 2, person: 'Warung Bu Siti', amount: 50000, date: '2026-04-01', isPayable: true },
  { id: 3, person: 'Budi Santoso', amount: 500000, date: '2026-03-20', isPayable: false },
])
</script>

<style scoped>
.debts-page {
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

.add-debt-btn {
  display: flex;
  align-items: center;
  gap: 12px;
  background: #fff !important;
  color: #000 !important;
  padding: 14px 24px !important;
  border-radius: 20px !important;
  font-weight: 800;
  cursor: pointer;
}

.stats-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

.stat-card {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.card-label {
  font-size: 10px;
  font-weight: 900;
  color: var(--text-secondary);
  letter-spacing: 1.5px;
}

.balance-amount {
  font-size: 32px;
  font-weight: 900;
}

.card-desc {
  font-size: 12px;
  color: var(--text-secondary);
}

.section-title {
  font-size: 20px;
  font-weight: 800;
  margin-bottom: 24px;
}

.debts-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.debt-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 32px;
  border-radius: 24px;
}

.debt-main {
  display: flex;
  align-items: center;
  gap: 16px;
  flex: 1;
}

.debt-avatar {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 900;
  font-size: 18px;
}

.debt-details {
  display: flex;
  flex-direction: column;
}

.person-name {
  font-size: 16px;
  font-weight: 800;
}

.debt-date {
  font-size: 12px;
  color: var(--text-secondary);
}

.debt-amount {
  display: flex;
  flex-direction: column;
  text-align: right;
  margin-right: 40px;
}

.amount-val {
  font-size: 18px;
  font-weight: 900;
}

.debt-type {
  font-size: 10px;
  font-weight: 800;
  color: var(--text-secondary);
}

.action-btn {
  padding: 8px 16px;
  border-radius: 10px;
  font-size: 12px;
  font-weight: 700;
  cursor: pointer;
}

.income { color: var(--income); }
.expense { color: var(--expense); }
</style>
