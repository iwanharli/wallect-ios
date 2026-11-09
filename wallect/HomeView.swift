import SwiftUI
import SwiftData

// MARK: - Animated Currency Display
struct AnimatedCurrencyText: View, Animatable {
    var value: Double
    var font: Font = .system(size: 36, weight: .black, design: .rounded)
    var color: Color = .white
    
    var animatableData: Double {
        get { value }
        set { value = newValue }
    }
    
    var body: some View {
        Text(CurrencyFormatter.format(value))
            .font(font)
            .foregroundColor(color)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
    }
}

struct HomeView: View {
    static var didInitialLoad = false
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var navigationState: NavigationState
    @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]
    @Query var wallets: [Wallet]
    @Query var budgets: [Budget]
    @Query var categories: [Category]
    @Query var debts: [Debt]
    
    @AppStorage("isDebtFeatureEnabled") var isDebtFeatureEnabled = false
    @AppStorage("userName") private var userName: String = "User"
    @State private var showingEditTransaction: Transaction? = nil
    @State private var showingAllTransactions = false
    @State private var showingProfile = false
    @State private var showingLogoutAlert = false
    @State private var showingAddBudget = false
    @State private var showingEditBudget: Budget? = nil
    @State private var showingBudgetDetail: Budget? = nil
    @State private var showingBudgetHistory = false
    @State private var showingStocks = false
    @State private var showingTransfer = false
    @State private var showingDebtList = false
    @State private var appeared = false
    @State private var isLoading = true
    @State private var historyFilter: String = "Semua"

    
    @ObservedObject var authManager = AppAuthManager.shared
    
    private var totalBalance: Double {
        wallets.reduce(0) { $0 + $1.currentBalance }
    }
    
    private var totalIncomeMonth: Double {
        let calendar = Calendar.current
        return transactions.filter {
            !$0.isExpense && 
            !$0.isSystem && 
            calendar.isDate($0.date, equalTo: .now, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpenseMonth: Double {
        let calendar = Calendar.current
        return transactions.filter {
            $0.isExpense && 
            !$0.isSystem && 
            calendar.isDate($0.date, equalTo: .now, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var goalWallets: [Wallet] {
        wallets.filter { $0.isGoal && !$0.isArchived }
    }
    
    private var isAnyOverlayShowing: Bool {
        showingAllTransactions || showingProfile || showingBudgetDetail != nil || showingBudgetHistory
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main Content Layer
                ZStack {
                    Theme.DynamicBackground()
                    
                    if isLoading {
                        HomeSkeletonView()
                            .transition(.opacity)
                    } else {
                        mainDashboard()
                            .transition(.opacity)
                    }
                }
                .blur(radius: isAnyOverlayShowing ? 15 : 0)
                .scaleEffect(isAnyOverlayShowing ? 0.94 : 1.0)
                .opacity(isAnyOverlayShowing ? 0.3 : 1.0)
                .animation(.spring(response: 0.55, dampingFraction: 0.82), value: isAnyOverlayShowing)
                
                // Transaction History View
                if showingAllTransactions {
                    AllTransactionsView(
                        isPresented: Binding(
                            get: { showingAllTransactions },
                            set: { 
                                showingAllTransactions = $0
                                if !$0 { historyFilter = "Semua" } // Reset filter on close
                            }
                        ),
                        initialType: historyFilter
                    )
                    .transition(.move(edge: .trailing))
                    .zIndex(10)
                }
                
                // User Profile View
                if showingProfile {
                    ProfileView(isPresented: $showingProfile)
                        .transition(.move(edge: .trailing))
                        .zIndex(11)
                }
                
                // Budget Detail View
                if let budget = showingBudgetDetail {
                    BudgetDetailView(isPresented: Binding(
                        get: { showingBudgetDetail != nil },
                        set: { if !$0 { showingBudgetDetail = nil } }
                    ), budget: budget)
                    .transition(.move(edge: .trailing))
                    .zIndex(12)
                }
                
                // Budget History View (RTL)
                if showingBudgetHistory {
                    BudgetHistoryView(isPresented: $showingBudgetHistory)
                        .transition(.move(edge: .trailing))
                        .zIndex(13)
                }
            }
            .onChange(of: isAnyOverlayShowing) { old, newValue in
                withAnimation(.easeInOut(duration: 0.3)) {
                    navigationState.isTabBarHidden = newValue
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $showingEditTransaction) { transaction in
            AddTransactionView(editTransaction: transaction)
                .presentationDetents([.fraction(0.85)])
        }
        .fullScreenCover(isPresented: $showingStocks) {
            StocksDummyView()
        }
        .sheet(isPresented: $showingAddBudget) {
            AddBudgetView()
                .presentationDetents([.fraction(0.85)])
        }
        .sheet(item: $showingEditBudget) { budget in
            AddBudgetView(editBudget: budget)
                .presentationDetents([.fraction(0.85)])
        }
        .sheet(isPresented: $showingTransfer) {
            TransferView()
                .presentationDetents([.fraction(0.8)])
        }
        .fullScreenCover(isPresented: $showingDebtList) {
            DebtListView(isPresented: $showingDebtList)
        }
        .onAppear {
            if HomeView.didInitialLoad {
                isLoading = false
            } else if isLoading {
                Task {
                    // Reduce delay for snappier feel
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    HomeView.didInitialLoad = true
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            isLoading = false
                        }
                    }
                }
            }
            
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
            Task {
                // Background Sync: Strategic delay to allow navigation transition to finish smoothly
                try? await Task.sleep(nanoseconds: 800_000_000)
                await SyncManager.shared.processQueue(context: modelContext)
                await SyncService.shared.fetchAll(context: modelContext)
            }
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Batal", role: .cancel) { }
            Button("Logout", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("Apakah Kamu yakin ingin keluar? Data lokal akan dihapus untuk keamanan.")
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func mainDashboard() -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 25) {
                // Header
                UnifiedHeaderCard(
                    userName: authManager.currentUser?.name ?? userName,
                    totalBalance: totalBalance,
                    monthlyIncome: totalIncomeMonth,
                    monthlyExpense: totalExpenseMonth,
                    profileAction: {
                        HapticManager.shared.impact(.medium)
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                            showingProfile = true
                        }
                    },
                    incomeAction: {
                        HapticManager.shared.impact(.medium)
                        historyFilter = "Pemasukan"
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                            showingAllTransactions = true
                        }
                    },
                    expenseAction: {
                        HapticManager.shared.impact(.medium)
                        historyFilter = "Pengeluaran"
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                            showingAllTransactions = true
                        }
                    }
                )
                .padding(.horizontal)
                
                // Goals Section
                if !goalWallets.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.cyan.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "target")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.cyan)
                            }
                            
                            Text("Targetmu")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(Theme.textMain)
                        }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(Array(goalWallets.enumerated()), id: \.element.id) { index, goal in
                                    NavigationLink(destination: WalletDetailView(wallet: goal)) {
                                        HomeGoalCard(goal: goal, index: index)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Budgets Section
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                            
                            Text("Anggaranmu")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(Theme.textMain)
                        }
                        Spacer()
                        
                        HStack(spacing: 15) {
                            Button(action: { 
                                HapticManager.shared.impact(.medium)
                                withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                                    showingBudgetHistory = true 
                                }
                            }) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundColor(Theme.textSecondary)
                                    .font(.title3)
                                    .padding(8)
                            }
                            .contentShape(Rectangle())
                            
                            Button(action: { 
                                HapticManager.shared.impact(.medium)
                                showingAddBudget = true 
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Theme.accent)
                                    .font(.title3)
                                    .padding(8)
                            }
                            .contentShape(Rectangle())
                        }
                    }
                    
                    let activeBudgets = budgets.filter { $0.isActive }
                        .sorted { ($0.endDate ?? Date.distantFuture) < ($1.endDate ?? Date.distantFuture) }
                    
                    if activeBudgets.isEmpty {
                        Text("Belum ada anggaran aktif. Tap + untuk membuat.")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                    } else {
                        VStack(spacing: 20) {
                            ForEach(activeBudgets) { budget in
                                BudgetRow(budget: budget, transactions: transactions) {
                                    HapticManager.shared.impact(.medium)
                                    withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                                        showingBudgetDetail = budget
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
                .padding(.horizontal)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                // Transactions List
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Theme.income.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Theme.income)
                            }
                            
                            Text("Transaksi Terakhir")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(Theme.textMain)
                        }
                        Spacer()
                        if !transactions.isEmpty {
                            Button(action: {
                                HapticManager.shared.impact(.medium)
                                withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                                    showingAllTransactions = true
                                }
                            }) {
                                Text("Lihat Semua")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(Theme.accent)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Theme.accent.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            .contentShape(Rectangle())
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    
                    if transactions.isEmpty {
                        EmptyStateView()
                            .opacity(appeared ? 1 : 0)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(Array(transactions.prefix(5).enumerated()), id: \.element.id) { index, transaction in
                                TransactionRow(transaction: transaction)
                                    .onTapGesture {
                                        if !transaction.isSystem {
                                            showingEditTransaction = transaction
                                        }
                                    }
                                    .swipeActions(edge: .trailing) {
                                        if !transaction.isSystem {
                                            Button(role: .destructive) {
                                                deleteTransaction(transaction)
                                            } label: {
                                                Label("Hapus", systemImage: "trash")
                                            }
                                        }
                                    }
                                    .opacity(appeared ? 1 : 0)
                                    .offset(y: appeared ? 0 : 20)
                                    .animation(
                                        .spring(response: 0.55, dampingFraction: 0.82)
                                        .delay(Double(index) * 0.08 + 0.3),
                                        value: appeared
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .padding(.bottom, 120)
            }
            .padding(.top, 20)
        }
        .refreshable {
            HapticManager.shared.impact(.medium)
            await SyncManager.shared.processQueue(context: modelContext)
            await SyncService.shared.fetchAll(context: modelContext)
        }
    }
    
    private func performLogout() {
        HapticManager.shared.impact(.medium)
        PersistenceService.shared.clearAllData(context: modelContext)
        authManager.logout()
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        HapticManager.shared.impact(.medium)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            TransactionService.shared.deleteTransaction(transaction, context: modelContext)
        }
    }
}

// MARK: - Balance Card
struct BalanceCard: View {
    let balance: Double
    let income: Double
    let expense: Double
    
    @State private var appeared = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("TOTAL SALDO")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(1.5)
                Spacer()
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.accent.opacity(0.6))
            }
            
            // Amount
            AnimatedCurrencyText(
                value: appeared ? balance : 0,
                font: .system(size: 38, weight: .bold, design: .rounded),
                color: .white
            )
            .animation(.spring(response: 0.6).delay(0.1), value: appeared)
            
            // Partition
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 1)
            
            // Stats (Minimalist)
            HStack(spacing: 25) {
                // Income
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .foregroundColor(Theme.income.opacity(0.8))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Masuk")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                        AnimatedCurrencyText(
                            value: appeared ? income : 0,
                            font: .system(size: 14, weight: .bold),
                            color: .white
                        )
                    }
                }
                
                // Expense
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.left.circle.fill")
                        .foregroundColor(Theme.expense.opacity(0.8))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Keluar")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                        AnimatedCurrencyText(
                            value: appeared ? expense : 0,
                            font: .system(size: 14, weight: .bold),
                            color: .white
                        )
                    }
                }
                
                Spacer()
            }
        }
        .padding(25)
        .background(
            ZStack {
                Theme.cardBackground
                    .overlay(
                        // Ethereal Glow
                        Circle()
                            .fill(Theme.accent.opacity(0.12))
                            .blur(radius: 40)
                            .offset(x: -80, y: -40)
                    )
                
                // Subtle Glass Border
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 15)
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}

struct HomeGoalCard: View {
    let goal: Wallet
    let index: Int
    
    private var progress: Double {
        guard let target = goal.targetAmount, target > 0 else { return 0 }
        return min(max(goal.currentBalance / target, 0), 1)
    }
    
    private var formattedDate: String? {
        guard let endDate = goal.endDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: endDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Icon & Progress Tag
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: goal.icon)
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.accent.opacity(0.2))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.accent.opacity(0.3), lineWidth: 0.5)
                    )
            }
            
            // Body: Name & Date Badge
            VStack(alignment: .leading, spacing: 6) {
                Text(goal.name)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if let date = formattedDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        Text(date)
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(6)
                }
            }
            
            Spacer(minLength: 0)
            
            // Footer: Progress Details & Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .bottom) {
                    NominalText(amount: goal.currentBalance, size: 14, color: .white)
                    Spacer()
                    Text("/")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.3))
                    NominalText(amount: goal.targetAmount ?? 0, size: 10, color: .white.opacity(0.5))
                }
                
                // Neon Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                        
                        // Inner Glow Layer
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .blur(radius: 2)
                            .frame(width: geo.size.width * CGFloat(progress))
                        
                        // Main Bar
                        Capsule()
                            .fill(.white)
                            .frame(width: geo.size.width * CGFloat(progress))
                            .shadow(color: .white.opacity(0.5), radius: 4, x: 0, y: 0)
                    }
                }
                .frame(height: 5)
            }
        }
        .padding(20)
        .frame(width: 175)
        .background(
            ZStack {
                // Background Gradient
                Theme.goalGradient(index: index)
                    .opacity(0.9)
                
                // Glass Effect
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial.opacity(0.2))
                
                // Subtle Top Light
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .clear, .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color.black.opacity(0.4), radius: 15, x: 0, y: 10)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .font(.subheadline.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}


#Preview {
    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Transaction.self, Wallet.self, Category.self, configurations: config)
        let sampleData = [
            Transaction(title: "Makan Siang", amount: 50000, category: "Food", isExpense: true),
            Transaction(title: "Gaji", amount: 5000000, category: "Work", isExpense: false),
            Transaction(title: "Beli Kopi", amount: 25000, category: "Food", isExpense: true)
        ]
        for transaction in sampleData {
            container.mainContext.insert(transaction)
        }
        return container
    }()
    
    HomeView()
        .modelContainer(container)
}
