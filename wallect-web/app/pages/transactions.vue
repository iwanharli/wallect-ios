<template>
  <div class="transactions-page">
    <header class="page-header fade-in">
      <div class="header-content">
        <h1 class="page-title">Riwayat Transaksi</h1>
        <p class="page-subtitle">Pantau setiap aliran masuk dan keluar dana Anda.</p>
      </div>
      <div class="header-tools">
        <div class="search-bar glass">
          <i class="fa-solid fa-magnifying-glass"></i>
          <input v-model="searchQuery" placeholder="Cari transaksi..." />
        </div>
      </div>
    </header>

    <div v-if="isLoading" class="loading-state">
      <div class="pulse-loader"></div>
      <span>Memuat riwayat...</span>
    </div>

    <div v-else class="transactions-container">
      <div class="filters-sidebar glass glass-card">
        <h3 class="filter-title">Filter</h3>
        <div class="filter-group">
          <label>KATEGORI</label>
          <select v-model="selectedCategory">
            <option value="">Semua Kategori</option>
            <option v-for="cat in categories" :key="cat.id" :value="cat.name">{{ cat.name }}</option>
          </select>
        </div>
        <div class="filter-group">
          <label>TIPE</label>
          <div class="toggle-group glass">
            <button :class="{ active: filterType === 'ALL' }" @click="filterType = 'ALL'">Semua</button>
            <button :class="{ active: filterType === 'INCOME' }" @click="filterType = 'INCOME'">Masuk</button>
            <button :class="{ active: filterType === 'EXPENSE' }" @click="filterType = 'EXPENSE'">Keluar</button>
          </div>
        </div>
      </div>

      <div class="transactions-list-main">
        <div v-if="filteredTransactions.length === 0" class="empty-state glass">
          <i class="fa-solid fa-folder-open empty-icon"></i>
          <p>Tidak ada transaksi yang ditemukan.</p>
        </div>
        
        <div v-else class="tx-table-container glass glass-card">
          <table class="tx-table">
            <thead>
              <tr>
                <th>TRANSAKSI</th>
                <th>KATEGORI</th>
                <th>TANGGAL</th>
                <th class="text-right">JUMLAH</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="tx in filteredTransactions" :key="tx.id" class="tx-row">
                <td>
                  <div class="tx-name-cell">
                    <span class="tx-icon-sm glass">{{ tx.icon || '💸' }}</span>
                    <span>{{ tx.title }}</span>
                  </div>
                </td>
                <td><span class="category-tag">{{ tx.category }}</span></td>
                <td><span class="tx-date">{{ formatDate(tx.createdAt) }}</span></td>
                <td class="text-right">
                  <span :class="tx.isExpense ? 'expense' : 'income'" class="tx-amount-v2">
                    {{ tx.isExpense ? '-' : '+' }} {{ formatCurrency(tx.amount) }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
const api = useWallectApi()
const transactions = ref([])
const categories = ref([])
const isLoading = ref(true)

const searchQuery = ref('')
const selectedCategory = ref('')
const filterType = ref('ALL') // ALL, INCOME, EXPENSE

const formatCurrency = (amount) => {
  return 'Rp. ' + (amount || 0).toLocaleString('id-ID')
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('id-ID', {
    day: '2-digit',
    month: 'short',
    year: 'numeric'
  })
}

const filteredTransactions = computed(() => {
  return transactions.value.filter(tx => {
    const matchesSearch = tx.title.toLowerCase().includes(searchQuery.value.toLowerCase())
    const matchesCategory = selectedCategory.value === '' || tx.category === selectedCategory.value
    const matchesType = filterType.value === 'ALL' || 
                       (filterType.value === 'INCOME' && !tx.isExpense) ||
                       (filterType.value === 'EXPENSE' && tx.isExpense)
    return matchesSearch && matchesCategory && matchesType
  })
})

onMounted(async () => {
  try {
    const [txData, catData] = await Promise.all([
      api.getTransactions(),
      api.getCategories()
    ])
    transactions.value = txData
    categories.value = catData
  } catch (e) {
    console.error('Failed to load transactions:', e)
  } finally {
    isLoading.value = false
  }
})
</script>

<style scoped>
.transactions-page {
  display: flex;
  flex-direction: column;
  gap: 40px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
}

.page-title {
  font-size: 32px;
  font-weight: 900;
  margin-bottom: 8px;
}

.page-subtitle {
  color: var(--text-secondary);
}

.search-bar {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 20px;
  border-radius: 18px;
  width: 300px;
}

.search-bar input {
  background: transparent;
  border: none;
  color: #fff;
  font-size: 14px;
  width: 100%;
}

.transactions-container {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 32px;
  align-items: start;
}

.filters-sidebar {
  padding: 32px;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.filter-title {
  font-size: 18px;
  font-weight: 800;
  margin-bottom: 8px;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.filter-group label {
  font-size: 10px;
  font-weight: 900;
  color: var(--text-secondary);
  letter-spacing: 1.5px;
}

.filter-group select {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 12px;
  border-radius: 12px;
  color: #fff;
}

.toggle-group {
  display: flex;
  padding: 4px;
  border-radius: 12px;
}

.toggle-group button {
  flex: 1;
  padding: 8px;
  border-radius: 8px;
  border: none;
  background: transparent;
  color: var(--text-secondary);
  font-size: 12px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s;
}

.toggle-group button.active {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
}

.tx-table-container {
  padding: 0;
  overflow: hidden;
}

.tx-table {
  width: 100%;
  border-collapse: collapse;
}

.tx-table th {
  text-align: left;
  padding: 20px 32px;
  font-size: 10px;
  font-weight: 900;
  color: var(--text-secondary);
  letter-spacing: 1.5px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.tx-row {
  transition: background 0.3s;
}

.tx-row:hover {
  background: rgba(255, 255, 255, 0.02);
}

.tx-table td {
  padding: 20px 32px;
  font-size: 14px;
}

.tx-name-cell {
  display: flex;
  align-items: center;
  gap: 16px;
  font-weight: 700;
}

.tx-icon-sm {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.category-tag {
  background: rgba(168, 218, 220, 0.1);
  color: var(--accent);
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 800;
}

.tx-date {
  color: var(--text-secondary);
  font-size: 13px;
}

.tx-amount-v2 {
  font-weight: 800;
  font-family: monospace;
}

.text-right { text-align: right; }
.income { color: var(--income); }
.expense { color: var(--expense); }

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  padding: 80px;
  border-radius: 32px;
  color: var(--text-secondary);
}

.empty-icon { font-size: 48px; }

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
  padding-top: 100px;
  color: var(--text-secondary);
}
</style>
