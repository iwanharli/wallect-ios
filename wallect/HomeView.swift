import SwiftUI
import SwiftData

// MARK: - Animated Currency Display
struct AnimatedCurrencyText: View, Animatable {
    var value: Double
    var font: Font = .system(size: 34, weight: .bold, design: .rounded)
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
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]
    @Query var wallets: [Wallet]
    @Query var categories: [Category]
    @AppStorage("userName") private var userName: String = "User"
    @State private var showingEditTransaction: Transaction? = nil
    @State private var showingAllTransactions = false
    @State private var showingProfile = false
    @State private var showingLogoutAlert = false
    @State private var appeared = false
    
    @ObservedObject var authManager = AppAuthManager.shared
    
    private var totalBalance: Double {
        let initial = wallets.reduce(0) { $0 + $1.initialBalance }
        let income = transactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
        let expense = transactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
        return initial + income - expense
    }
    
    private var totalIncomeMonth: Double {
        let calendar = Calendar.current
        return transactions.filter {
            !$0.isExpense && calendar.isDate($0.date, equalTo: .now, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpenseMonth: Double {
        let calendar = Calendar.current
        return transactions.filter {
            $0.isExpense && calendar.isDate($0.date, equalTo: .now, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Selamat Datang,")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                            Text(authManager.currentUser?.name ?? userName)
                                .font(.title2.bold())
                                .foregroundColor(Theme.textMain)
                        }
                        Spacer()
                        Menu {
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                showingProfile = true
                            } label: {
                                Label("Lihat Profil", systemImage: "person.crop.circle")
                            }
                        } label: {
                            Circle()
                                .fill(Theme.glassGradient)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .padding(.horizontal)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -10)
                    
                    // Wallets Horizontal Overview
                    if !wallets.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(wallets) { wallet in
                                    let walletBalance = wallet.initialBalance + (wallet.transactions?.reduce(0) { $0 + ($1.isExpense ? -$1.amount : $1.amount) } ?? 0)
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: wallet.icon)
                                            .font(.caption)
                                            .foregroundColor(Theme.walletAccent(for: wallet.walletType))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(wallet.name)
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(Theme.textSecondary)
                                            Text(CurrencyFormatter.format(walletBalance))
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(Theme.textMain)
                                        }
                                    }
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 10)
                                    .background(
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Theme.cardBackground.opacity(0.5))
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Theme.walletGradient(for: wallet.walletType))
                                                .opacity(0.12)
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Theme.walletAccent(for: wallet.walletType).opacity(0.2), lineWidth: 1)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                    }
                    
                    // Balance Card
                    BalanceCard(
                        balance: totalBalance,
                        income: totalIncomeMonth,
                        expense: totalExpenseMonth
                    )
                    .padding(.horizontal)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.95)
                    
                    // Transactions List
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Transaksi Terakhir")
                                .font(.headline)
                                .foregroundColor(Theme.textMain)
                            Spacer()
                            if !transactions.isEmpty {
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    showingAllTransactions = true
                                }) {
                                    Text("Lihat Semua")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.accent)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .opacity(appeared ? 1 : 0)
                        
                        if transactions.isEmpty {
                            EmptyStateView(action: seedDummyData)
                                .opacity(appeared ? 1 : 0)
                        } else {
                            List {
                                ForEach(Array(transactions.prefix(6).enumerated()), id: \.element.id) { index, transaction in
                                    TransactionRow(transaction: transaction)
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                        .onTapGesture {
                                            showingEditTransaction = transaction
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                deleteTransaction(transaction)
                                            } label: {
                                                Label("Hapus", systemImage: "trash")
                                            }
                                        }
                                        .opacity(appeared ? 1 : 0)
                                        .offset(y: appeared ? 0 : 20)
                                        .animation(
                                            .spring(response: 0.5, dampingFraction: 0.7)
                                            .delay(Double(index) * 0.08 + 0.3),
                                            value: appeared
                                        )
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .scrollDisabled(true)
                            .frame(height: CGFloat(min(transactions.count, 6)) * 95) // Increased multiplier to prevent truncation
                        }
                    }
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 120)
                }
                .padding(.top, 20)
            }
        }
        .fullScreenCover(isPresented: $showingAllTransactions) {
            AllTransactionsView()
        }
        .fullScreenCover(isPresented: $showingProfile) {
            ProfileView()
        }
        .sheet(item: $showingEditTransaction) { transaction in
            AddTransactionView(editTransaction: transaction)
                .presentationDetents([.fraction(0.85)])
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
            Task {
                await SyncService.shared.fetchAll(context: modelContext)
            }
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Batal", role: .cancel) { }
            Button("Logout", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("Apakah Anda yakin ingin keluar? Data lokal akan dihapus untuk keamanan.")
        }
    }
    
    private func performLogout() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        PersistenceService.shared.clearAllData(context: modelContext)
        authManager.logout()
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            TransactionService.shared.deleteTransaction(transaction, context: modelContext)
        }
    }
    
    private func seedDummyData() {
        let dummyData = [
            Transaction(title: "Gaji Bulanan", amount: 15000000, category: "Work", isExpense: false),
            Transaction(title: "Makan Siang Bakso", amount: 25000, category: "Food", isExpense: true),
            Transaction(title: "Bensin Motor", amount: 50000, category: "Transport", isExpense: true),
            Transaction(title: "Langganan Netflix", amount: 186000, category: "Entertainment", isExpense: true),
            Transaction(title: "Belanja Bulanan", amount: 750000, category: "Shopping", isExpense: true),
            Transaction(title: "Bonus Project", amount: 2500000, category: "Work", isExpense: false),
            Transaction(title: "Tiket Bioskop", amount: 50000, category: "Entertainment", isExpense: true)
        ]
        for transaction in dummyData {
            modelContext.insert(transaction)
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
