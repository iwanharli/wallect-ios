<template>
  <div class="dashboard-neon-layout fade-in">
    <!-- Main Statistics Column -->
    <div class="main-stats-column">
      <header class="stats-header">
        <div class="header-left">
          <h1 class="stats-title">Dashboard</h1>
          <p class="stats-subtitle">LIVE FINANCIAL ANALYTICS</p>
        </div>
        <div class="project-selector glass">
          <span>iOS App Project</span>
          <i class="fa-solid fa-chevron-down"></i>
        </div>
      </header>

      <!-- Visual Activity Section -->
      <section class="activity-visual-grid">
        <div class="activity-card balance-card-v3 glass-premium">
          <div class="card-header-v2">
            <h3 class="v2-title">Total Balance</h3>
            <p class="v2-subtitle">Synced with {{ wallets.length }} Accounts</p>
          </div>
          <div class="balance-display-v3">
            <div class="balance-main-v3">
              <span class="currency-prefix">Rp.</span>
              <h1 class="main-amount-text">{{ (totalBalance || 0).toLocaleString('id-ID') }}</h1>
            </div>
            <div class="balance-trend-v3 income">
              <i class="fa-solid fa-arrow-trend-up"></i>
              <span>+2.4% this week</span>
            </div>
          </div>
          <!-- Subtle Background Accent -->
          <div class="card-wave-bg">
            <svg viewBox="0 0 400 100" preserveAspectRatio="none">
              <path d="M0,50 C150,100 250,0 400,50 L400,100 L0,100 Z" fill="url(#grad1)" opacity="0.1" />
              <defs>
                <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="0%">
                  <stop offset="0%" style="stop-color:var(--accent);stop-opacity:1" />
                  <stop offset="100%" style="stop-color:var(--income);stop-opacity:1" />
                </linearGradient>
              </defs>
            </svg>
          </div>
        </div>
        
        <div class="activity-card bar-card glass-premium">
          <div class="card-header-v2">
            <h3 class="v2-title">Monthly Trends</h3>
            <div class="header-right-v3">
              <span class="trend-badge pos">+12% vs LY</span>
            </div>
          </div>
          <div class="bar-chart-v3">
            <div v-for="m in monthlyStats" :key="m.month" class="bar-pair-v3">
              <div class="bar-group-v3">
                <div class="bar-v3 income" :style="{ height: m.incomeH + '%' }">
                  <div class="bar-tooltip">Rp. {{ m.incomeV }}k</div>
                </div>
                <div class="bar-v3 expense" :style="{ height: m.expenseH + '%' }">
                  <div class="bar-tooltip">Rp. {{ m.expenseV }}k</div>
                </div>
              </div>
              <span class="month-label-v3">{{ m.month }}</span>
            </div>
          </div>
          <div class="bar-stats-v3">
            <div class="b-stat-v3"><span class="dot income"></span> Income</div>
            <div class="b-stat-v3"><span class="dot expense"></span> Expense</div>
          </div>
        </div>
      </section>

      <!-- Gradient Vertical Cards -->
      <section class="gradient-cards-grid">
        <div class="v-card grad-purple">
          <i class="fa-solid fa-hand-holding-dollar"></i>
          <span class="v-label">PENDING DEBTS</span>
          <span class="v-val">{{ debts.filter(d => !d.isPaid).length }}</span>
        </div>
        <div class="v-card grad-dark">
          <i class="fa-solid fa-bullseye"></i>
          <span class="v-label">ONGOING GOALS</span>
          <span class="v-val">{{ wallets.filter(w => w.isGoal).length }}</span>
        </div>
        <div class="v-card grad-teal">
          <i class="fa-solid fa-wallet"></i>
          <span class="v-label">ACTIVE BUDGETS</span>
          <span class="v-val">{{ budgets.length }}</span>
        </div>
        <div class="v-card grad-green">
          <i class="fa-solid fa-chart-line"></i>
          <span class="v-label">TOTAL PROGRESS</span>
          <div class="v-progress-ring">
            <span class="v-val">{{ overallGoalProgress }}%</span>
          </div>
        </div>
      </section>

      <!-- Bottom Mini Stats -->
      <section class="mini-stats-grid">
        <div class="m-card glass">
          <i class="fa-solid fa-hand-holding-medical"></i>
          <div class="m-info"><span>Mo. Income</span><strong>{{ formatCurrencyShort(incomeMonth) }}</strong></div>
        </div>
        <div class="m-card glass">
          <i class="fa-solid fa-receipt"></i>
          <div class="m-info"><span>Mo. Expense</span><strong>{{ formatCurrencyShort(expenseMonth) }}</strong></div>
        </div>
        <div class="m-card glass">
          <i class="fa-solid fa-calendar-check"></i>
          <div class="m-info"><span>Activities</span><strong>{{ recentTransactions.length }}</strong></div>
        </div>
        <div class="m-card glass">
          <i class="fa-solid fa-vault"></i>
          <div class="m-info"><span>Wallets</span><strong>{{ wallets.length }}</strong></div>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup>
const api = useWallectApi()
const wallets = ref([])
const recentTransactions = ref([])
const budgets = ref([])
const debts = ref([])
const isLoading = ref(true)

const overallGoalProgress = computed(() => {
  const goals = wallets.value.filter(w => w.isGoal && w.targetAmount)
  if (goals.length === 0) return 0
  const totalTarget = goals.reduce((acc, g) => acc + (g.targetAmount || 0), 0)
  const totalCurrent = goals.reduce((acc, g) => acc + (g.balance || 0), 0)
  return Math.round((totalCurrent / totalTarget) * 100)
})

const totalBalance = computed(() => {
  return wallets.value.reduce((acc, w) => acc + (w.balance || 0), 0)
})

// Dummy Monthly Trends Data (Full Year)
const monthlyStats = ref([
  { month: 'Jan', incomeH: 45, expenseH: 30, incomeV: '12.5', expenseV: '8.2' },
  { month: 'Feb', incomeH: 55, expenseH: 40, incomeV: '15.2', expenseV: '10.5' },
  { month: 'Mar', incomeH: 75, expenseH: 60, incomeV: '18.8', expenseV: '14.2' },
  { month: 'Apr', incomeH: 65, expenseH: 45, incomeV: '16.5', expenseV: '11.8' },
  { month: 'May', incomeH: 85, expenseH: 50, incomeV: '21.0', expenseV: '12.5' },
  { month: 'Jun', incomeH: 95, expenseH: 35, incomeV: '24.5', expenseV: '9.8' },
  { month: 'Jul', incomeH: 70, expenseH: 55, incomeV: '19.2', expenseV: '15.0' },
  { month: 'Aug', incomeH: 60, expenseH: 40, incomeV: '14.5', expenseV: '10.2' },
  { month: 'Sep', incomeH: 80, expenseH: 65, incomeV: '20.8', expenseV: '17.5' },
  { month: 'Oct', incomeH: 90, expenseH: 50, incomeV: '23.4', expenseV: '12.8' },
  { month: 'Nov', incomeH: 85, expenseH: 60, incomeV: '21.5', expenseV: '15.2' },
  { month: 'Dec', incomeH: 100, expenseH: 40, incomeV: '28.0', expenseV: '9.5' }
])

const incomeMonth = computed(() => {
  return recentTransactions.value
    .filter(tx => !tx.isExpense)
    .reduce((acc, tx) => acc + (tx.amount || 0), 0)
})

const expenseMonth = computed(() => {
  return recentTransactions.value
    .filter(tx => tx.isExpense)
    .reduce((acc, tx) => acc + (tx.amount || 0), 0)
})

const formatCurrencyShort = (amount) => {
  let val = amount
  if (amount >= 1000000) val = (amount / 1000000).toFixed(1) + 'M'
  else if (amount >= 1000) val = (amount / 1000).toFixed(0) + 'k'
  return 'Rp. ' + val
}

onMounted(async () => {
  try {
    const [walletsData, txData, budgetsData, debtsData] = await Promise.all([
      api.getWallets(),
      api.getTransactions(),
      api.getBudgets(),
      api.getDebts()
    ])
    wallets.value = walletsData || []
    recentTransactions.value = (txData || []).slice(0, 5) // Last 5
    budgets.value = budgetsData || []
    debts.value = debtsData || []
  } catch (e) {
    console.error('Failed to fetch dashboard data:', e)
  } finally {
    isLoading.value = false
  }
})
</script>

<style scoped>
.dashboard-neon-layout {
  display: flex;
  gap: 0;
  margin: -20px -60px -60px;
  min-height: calc(100vh - 100px);
  background: transparent;
}

/* Main Statistics Column */
.main-stats-column {
  flex: 1;
  padding: 40px 60px;
  display: flex;
  flex-direction: column;
  gap: 40px;
}

.stats-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stats-title {
  font-size: 42px;
  font-weight: 900;
  letter-spacing: -1px;
}

.stats-subtitle {
  font-size: 10px;
  font-weight: 900;
  color: var(--text-secondary);
  letter-spacing: 2px;
}

.project-selector {
  padding: 10px 24px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 14px;
  font-weight: 700;
  background: #1A1A1A;
}

/* Activity Grid */
.activity-visual-grid {
  display: grid;
  grid-template-columns: 1fr 2.5fr;
  gap: 24px;
}

.activity-card {
  border-radius: 32px;
  padding: 32px;
  position: relative;
  overflow: hidden;
}

.balance-card-v3 {
  background: linear-gradient(135deg, rgba(223, 255, 0, 0.05) 0%, rgba(0, 0, 0, 0.2) 100%);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  border: 1px solid rgba(223, 255, 0, 0.15) !important;
}

.balance-display-v3 {
  margin-top: 30px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  z-index: 2;
}

.balance-main-v3 {
  display: flex;
  align-items: baseline;
  gap: 12px;
}

.currency-prefix {
  font-size: 24px;
  font-weight: 800;
  color: var(--accent);
  opacity: 0.8;
}

.main-amount-text {
  font-size: 38px;
  font-weight: 900;
  letter-spacing: -1px;
  background: linear-gradient(180deg, #fff 0%, #aaa 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  filter: drop-shadow(0 0 20px rgba(255, 255, 255, 0.1));
  line-height: 1.2;
}

.balance-trend-v3 {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 700;
}

.balance-trend-v3.income { color: var(--income); }

.card-wave-bg {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 80px;
  pointer-events: none;
}

.card-wave-bg svg { width: 100%; height: 100%; }

.v2-title { font-size: 18px; font-weight: 800; margin-bottom: 4px; }

.bar-chart-v3 {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  height: 140px;
  margin: 35px 0 10px;
  position: relative;
}

.bar-pair-v3 {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  flex: 1;
}

.bar-group-v3 {
  display: flex;
  align-items: flex-end;
  gap: 3px;
  height: 100px;
  width: 100%;
  justify-content: center;
}

.bar-v3 {
  width: 6px;
  border-radius: 3px;
  transition: all 0.6s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  position: relative;
}

.bar-v3:hover .bar-tooltip {
  opacity: 1;
  transform: translateX(-50%) translateY(-10px);
}

.bar-tooltip {
  position: absolute;
  top: -30px;
  left: 50%;
  transform: translateX(-50%) translateY(0);
  background: #fff;
  color: #000;
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 10px;
  font-weight: 900;
  white-space: nowrap;
  opacity: 0;
  transition: all 0.3s;
  pointer-events: none;
  z-index: 10;
}

.bar-v3.income { background: var(--income); box-shadow: 0 0 15px rgba(0, 255, 148, 0.3); }
.bar-v3.expense { background: var(--expense); box-shadow: 0 0 15px rgba(255, 62, 62, 0.3); }

.month-label-v3 {
  font-size: 10px;
  font-weight: 800;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 1px;
}

.bar-stats-v3 {
  display: flex;
  gap: 20px;
  font-size: 11px;
  font-weight: 800;
}

.b-stat-v3 { display: flex; align-items: center; gap: 6px; }

.trend-badge {
  font-size: 10px;
  font-weight: 900;
  padding: 4px 10px;
  border-radius: 20px;
}

.trend-badge.pos { background: rgba(0, 255, 148, 0.1); color: var(--income); }

.dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; }
.dot.income { background: var(--income); }
.dot.expense { background: var(--expense); }

/* Gradient Vertical Cards */
.gradient-cards-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
}

.v-card {
  height: 240px;
  border-radius: 32px;
  padding: 32px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  position: relative;
  transition: transform 0.3s ease;
}

.v-card:hover { transform: translateY(-10px); }

.v-card i { font-size: 24px; }
.v-label { font-size: 10px; font-weight: 900; letter-spacing: 1px; opacity: 0.8; }
.v-val { font-size: 42px; font-weight: 900; }

.grad-purple { background: linear-gradient(180deg, rgba(157, 78, 221, 0.15) 0%, rgba(0, 0, 0, 0.2) 100%); color: #9D4EDD; border: 1px solid rgba(157, 78, 221, 0.1); }
.grad-dark { background: rgba(255, 255, 255, 0.03); color: #fff; border: 1px solid rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); }
.grad-teal { background: linear-gradient(180deg, rgba(76, 201, 240, 0.15) 0%, rgba(0, 0, 0, 0.2) 100%); color: #4CC9F0; border: 1px solid rgba(76, 201, 240, 0.1); }
.grad-green { background: linear-gradient(180deg, rgba(223, 255, 0, 0.1) 0%, rgba(0, 0, 0, 0.2) 100%); color: var(--accent); border: 1px solid rgba(223, 255, 0, 0.1); }

.v-progress-ring {
  margin-top: auto;
  position: relative;
}

/* Mini Stats */
.mini-stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.m-card {
  padding: 18px 24px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  background: #111;
}

.m-card i { color: var(--text-secondary); font-size: 18px; }
.m-info { display: flex; flex-direction: column; }
.m-info span { font-size: 10px; color: var(--text-secondary); font-weight: 700; }
.m-info strong { font-size: 16px; font-weight: 800; }

@media (max-width: 1440px) {
  .main-stats-column { padding: 40px; }
}
</style>
