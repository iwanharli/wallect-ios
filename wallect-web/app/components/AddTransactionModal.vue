<template>
  <Teleport to="body">
    <transition name="modal-fade">
      <div v-if="isOpen" class="modal-overlay" @click.self="$emit('close')">
        <div class="modal-container glass glass-premium scale-in">
          <header class="modal-header">
            <h2 class="modal-title">Transaksi Baru</h2>
            <button class="close-btn" @click="$emit('close')">
              <i class="fa-solid fa-xmark"></i>
            </button>
          </header>

          <form @submit.prevent="handleSubmit" class="modal-form">
            <div class="type-selector-wrapper glass">
              <div class="type-active-bg" :class="{ 'is-income': !form.isExpense }"></div>
              <button 
                type="button" 
                :class="{ active: form.isExpense }" 
                @click="form.isExpense = true"
                class="type-toggle"
              >Pengeluaran</button>
              <button 
                type="button" 
                :class="{ active: !form.isExpense }" 
                @click="form.isExpense = false"
                class="type-toggle"
              >Pemasukan</button>
            </div>

            <div class="form-field">
              <label>JUMLAH</label>
              <div class="amount-input-group">
                <span class="currency-label">Rp</span>
                <input v-model.number="form.amount" type="number" placeholder="0" class="main-amount-input" required />
              </div>
            </div>

            <div class="form-field">
              <label>KETERANGAN</label>
              <input v-model="form.title" placeholder="Bayar Makan Siang" class="premium-input" required />
            </div>

            <div class="form-grid">
              <div class="form-field">
                <label>DOMPET</label>
                <div class="select-wrapper">
                  <select v-model="form.walletId" class="premium-select" required>
                    <option disabled value="">Pilih Dompet</option>
                    <option v-for="w in wallets" :key="w.id" :value="w.id">{{ w.name }}</option>
                  </select>
                </div>
              </div>
              <div class="form-field">
                <label>KATEGORI</label>
                <div class="select-wrapper">
                  <select v-model="form.category" class="premium-select" required>
                    <option disabled value="">Pilih Kategori</option>
                    <option v-for="c in categories" :key="c.id" :value="c.name">{{ c.name }}</option>
                  </select>
                </div>
              </div>
            </div>

            <button type="submit" class="submit-btn-premium" :disabled="isSubmitting">
              <span v-if="!isSubmitting">
                <i class="fa-solid fa-plus"></i> Simpan Transaksi
              </span>
              <span v-else class="loader-v3"></span>
            </button>
          </form>
        </div>
      </div>
    </transition>
  </Teleport>
</template>

<script setup>
const props = defineProps(['isOpen'])
const emit = defineEmits(['close', 'success'])

const api = useWallectApi()
const wallets = ref([])
const categories = ref([])
const isSubmitting = ref(false)

const form = ref({
  title: '',
  amount: 0,
  isExpense: true,
  walletId: '',
  category: '',
  icon: '💸'
})

onMounted(async () => {
  try {
    const [wData, cData] = await Promise.all([
      api.getWallets(),
      api.getCategories()
    ])
    wallets.value = wData || []
    categories.value = cData || []
  } catch (e) {
    console.error('Failed to load add-tx dependencies:', e)
  }
})

const handleSubmit = async () => {
  if (isSubmitting.value) return
  isSubmitting.value = true
  try {
    await api.createTransaction(form.value)
    emit('success')
    emit('close')
    // Reset form
    form.value = { title: '', amount: 0, isExpense: true, walletId: '', category: '', icon: '💸' }
  } catch (e) {
    console.error('Create transaction error:', e)
  } finally {
    isSubmitting.value = false
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.45); /* Thinner backdrop as requested */
  backdrop-filter: blur(12px);
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-container {
  width: 520px;
  padding: 40px;
  border-radius: 40px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 35px;
}

.modal-title {
  font-size: 26px;
  font-weight: 900;
  letter-spacing: -0.5px;
  background: linear-gradient(180deg, #fff 0%, #aaa 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}

.close-btn {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #fff;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: rotate(90deg);
}

.modal-form {
  display: flex;
  flex-direction: column;
  gap: 28px;
}

/* Segmented Toggle Styling */
.type-selector-wrapper {
  display: flex;
  position: relative;
  background: rgba(255, 255, 255, 0.05);
  padding: 5px;
  border-radius: 18px;
  border: 1px solid rgba(255, 255, 255, 0.05);
}

.type-active-bg {
  position: absolute;
  top: 5px;
  left: 5px;
  width: calc(50% - 5px);
  height: calc(100% - 10px);
  background: rgba(230, 57, 70, 0.2);
  border-radius: 14px;
  transition: all 0.4s cubic-bezier(0.18, 0.89, 0.32, 1.28);
}

.type-active-bg.is-income {
  left: 50%;
  background: rgba(0, 255, 178, 0.2);
}

.type-toggle {
  flex: 1;
  padding: 12px;
  border: none;
  background: transparent;
  color: var(--text-secondary);
  font-weight: 800;
  font-size: 14px;
  cursor: pointer;
  z-index: 1;
  transition: color 0.3s;
}

.type-toggle.active {
  color: #fff;
}

/* Amount Input Scaling */
.amount-input-group {
  display: flex;
  align-items: baseline;
  justify-content: center;
  gap: 15px;
  padding: 10px 0;
  border-bottom: 2px solid rgba(255, 255, 255, 0.05);
  transition: border-color 0.3s;
}

.amount-input-group:focus-within {
  border-color: var(--accent);
}

.currency-label {
  font-size: 28px;
  font-weight: 900;
  color: var(--accent);
  opacity: 0.8;
}

.main-amount-input {
  background: transparent;
  border: none;
  font-size: 54px;
  font-weight: 950;
  color: #fff;
  width: 100%;
  text-align: left;
  outline: none;
  font-family: 'Outfit', sans-serif;
}

.main-amount-input::placeholder { color: rgba(255, 255, 255, 0.1); }

/* Premium Fields */
.form-field label {
  font-size: 10px;
  font-weight: 900;
  color: var(--text-secondary);
  letter-spacing: 2px;
  margin-bottom: 10px;
}

.premium-input, .premium-select {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.08);
  padding: 18px 24px;
  border-radius: 20px;
  color: #fff;
  font-size: 15px;
  width: 100%;
  transition: all 0.3s;
  outline: none;
}

.premium-input:focus, .premium-select:focus {
  background: rgba(255, 255, 255, 0.06);
  border-color: var(--accent);
  box-shadow: 0 0 20px rgba(223, 255, 0, 0.1);
}

.select-wrapper {
  position: relative;
}

.select-wrapper::after {
  content: '\f078';
  font-family: 'Font Awesome 6 Free';
  font-weight: 900;
  position: absolute;
  right: 20px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 10px;
  color: var(--text-secondary);
  pointer-events: none;
}

.premium-select {
  appearance: none;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

/* Submit Button Premium */
.submit-btn-premium {
  margin-top: 15px;
  background: #fff;
  color: #000;
  border: none;
  padding: 22px;
  border-radius: 24px;
  font-weight: 900;
  font-size: 16px;
  letter-spacing: 1px;
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
}

.submit-btn-premium:hover:not(:disabled) {
  background: var(--accent);
  transform: translateY(-5px) scale(1.02);
  box-shadow: 0 20px 40px rgba(223, 255, 0, 0.2);
}

.submit-btn-premium:active {
  transform: scale(0.98);
}

.submit-btn-premium:disabled {
  opacity: 0.4;
  filter: grayscale(1);
}

/* Animations */
.modal-fade-enter-active, .modal-fade-leave-active { transition: opacity 0.4s ease; }
.modal-fade-enter-from, .modal-fade-leave-to { opacity: 0; }

.scale-in {
  animation: scaleIn 0.5s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes scaleIn {
  from { opacity: 0; transform: scale(0.9) translateY(30px); }
  to { opacity: 1; transform: scale(1) translateY(0); }
}

.loader-v3 {
  width: 20px;
  height: 20px;
  border: 3px solid rgba(0,0,0,0.1);
  border-top-color: #000;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
