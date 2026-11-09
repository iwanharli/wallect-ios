<template>
  <div class="wallets-page">
    <header class="page-header fade-in">
      <div class="header-content">
        <h1 class="page-title">Kelola Dompet</h1>
        <p class="page-subtitle">Atur semua sumber dana dan alokasi asetmu.</p>
      </div>
      <button class="add-wallet-btn glass-card premium-glow" @click="showAddModal = true">
        <span class="btn-icon">+</span>
        <span>Dompet Baru</span>
      </button>
    </header>

    <div v-if="isLoading" class="loading-state">
      <div class="pulse-loader"></div>
      <span>Mensinkronisasi aset...</span>
    </div>

    <div v-else class="wallets-grid">
      <div v-for="wallet in wallets" :key="wallet.id" class="wallet-card glass glass-card fade-in">
        <div class="wallet-type-chip">{{ wallet.type || 'Standard' }}</div>
        <div class="wallet-visual">
          <div class="wallet-icon-large glass">{{ wallet.icon || '🏦' }}</div>
          <div class="wallet-info">
            <h3 class="wallet-name">{{ wallet.name }}</h3>
            <p class="wallet-id">ID: {{ wallet.id.toString().slice(-6) }}</p>
          </div>
        </div>
        <div class="wallet-balance-section">
          <span class="balance-label">SALDO SAAT INI</span>
          <div class="balance-amount">{{ formatCurrency(wallet.balance) }}</div>
        </div>
        <div class="wallet-actions">
          <button class="action-btn glass">Edit</button>
          <button class="action-btn glass">Transfer</button>
        </div>
      </div>
    </div>

    <!-- Add Wallet Modal -->
    <Teleport to="body">
      <transition name="modal-fade">
        <div v-if="showAddModal" class="modal-overlay" @click.self="showAddModal = false">
          <div class="modal-container glass glass-card scale-in">
            <h2 class="modal-title">Tambah Dompet Baru</h2>
            <form @submit.prevent="handleAddWallet" class="modal-form">
              <div class="form-field">
                <label>NAMA DOMPET</label>
                <input v-model="newWallet.name" placeholder="Misal: Tabungan Haji" required />
              </div>
              <div class="form-field">
                <label>SALDO AWAL</label>
                <input v-model.number="newWallet.balance" type="number" placeholder="0" required />
              </div>
              <div class="modal-actions">
                <button type="button" class="cancel-btn" @click="showAddModal = false">Batal</button>
                <button type="submit" class="submit-btn" :disabled="isSubmitting">Buat Dompet</button>
              </div>
            </form>
          </div>
        </div>
      </transition>
    </Teleport>
  </div>
</template>

<script setup>
const api = useWallectApi()
const wallets = ref([])
const isLoading = ref(true)
const showAddModal = ref(false)
const isSubmitting = ref(false)

const newWallet = ref({
  name: '',
  balance: 0,
  icon: '💳',
  type: 'SAVINGS'
})

const formatCurrency = (amount) => {
  return 'Rp. ' + (amount || 0).toLocaleString('id-ID')
}

const fetchWallets = async () => {
  isLoading.value = true
  try {
    wallets.value = await api.getWallets()
  } catch (e) {
    console.error('Fetch wallets error:', e)
  } finally {
    isLoading.value = false
  }
}

const handleAddWallet = async () => {
  isSubmitting.value = true
  try {
    await api.createWallet(newWallet.value)
    await fetchWallets()
    showAddModal.value = false
    newWallet.value = { name: '', balance: 0, icon: '💳', type: 'SAVINGS' }
  } catch (e) {
    console.error('Create wallet error:', e)
  } finally {
    isSubmitting.value = false
  }
}

onMounted(fetchWallets)
</script>

<style scoped>
.wallets-page {
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

.add-wallet-btn {
  display: flex;
  align-items: center;
  gap: 12px;
  background: #fff !important;
  color: #000 !important;
  padding: 14px 24px !important;
  border-radius: 20px !important;
  font-weight: 800;
}

.wallets-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 24px;
}

.wallet-card {
  height: 240px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  position: relative;
  overflow: hidden;
}

.wallet-type-chip {
  position: absolute;
  top: 20px;
  right: 20px;
  font-size: 10px;
  font-weight: 900;
  letter-spacing: 1px;
  padding: 4px 10px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 20px;
  color: var(--accent);
}

.wallet-visual {
  display: flex;
  align-items: center;
  gap: 16px;
}

.wallet-icon-large {
  width: 56px;
  height: 56px;
  font-size: 28px;
  border-radius: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.wallet-name {
  font-size: 18px;
  font-weight: 800;
}

.wallet-id {
  font-size: 11px;
  color: var(--text-secondary);
  font-family: monospace;
}

.wallet-balance-section {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.balance-label {
  font-size: 10px;
  font-weight: 800;
  color: var(--text-secondary);
  letter-spacing: 1.5px;
}

.balance-amount {
  font-size: 24px;
  font-weight: 900;
}

.wallet-actions {
  display: flex;
  gap: 12px;
}

.action-btn {
  flex: 1;
  padding: 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 700;
  cursor: pointer;
}

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
  padding-top: 100px;
  color: var(--text-secondary);
}

/* Modal Styling */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  backdrop-filter: blur(20px);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-container {
  width: 400px;
  padding: 40px;
  border-radius: 32px;
}

.modal-title {
  margin-bottom: 32px;
  font-weight: 900;
}

.modal-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-field label {
  font-size: 10px;
  font-weight: 800;
  color: var(--text-secondary);
}

.form-field input {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 14px 20px;
  border-radius: 14px;
  color: #fff;
}

.modal-actions {
  display: flex;
  gap: 12px;
  margin-top: 20px;
}

.submit-btn {
  flex: 2;
  background: #fff;
  color: #000;
  border: none;
  padding: 14px;
  border-radius: 14px;
  font-weight: 800;
  cursor: pointer;
}

.cancel-btn {
  flex: 1;
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
  border: none;
  padding: 14px;
  border-radius: 14px;
  cursor: pointer;
}
</style>
