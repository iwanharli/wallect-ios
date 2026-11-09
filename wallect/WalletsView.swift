import SwiftUI
import SwiftData

struct WalletsView: View {
    static var didInitialLoad = false
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var navigationState: NavigationState
    @Query var wallets: [Wallet]
    @Query var transactions: [Transaction]
    @Query var allCategories: [Category]
    @Query var debts: [Debt]
    
    @AppStorage("isDebtFeatureEnabled") var isDebtFeatureEnabled = false
    
    @State private var showingAddWallet = false
    @State private var showingTransfer = false
    @State private var showingDebtList = false
    enum ViewSegment: String, CaseIterable {
        case wallets = "DOMPET"
        case goals = "GOAL"
        case debt = "DEBT"
    }
    
    @State private var selectedSegment: ViewSegment = .wallets
    
    enum GoalFilter: String, CaseIterable {
        case active = "AKTIF"
        case history = "RIWAYAT"
    }
    @State private var selectedGoalFilter: GoalFilter = .active
    @State private var fabPulse = false
    @State private var isLoading = true

    
    private var totalBalance: Double {
        wallets.reduce(0) { $0 + $1.currentBalance }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                // Asset Glow
                Circle()
                    .fill(Theme.accent.opacity(0.1))
                    .blur(radius: 100)
                    .frame(width: 300)
                    .offset(x: -150, y: -250)
                
                Circle()
                    .fill(Color(hex: "FFD700").opacity(0.05))
                    .blur(radius: 100)
                    .frame(width: 300)
                    .offset(x: 150, y: 150)
                
                if isLoading {
                    WalletsSkeletonView()
                        .transition(.opacity)
                } else {
                    VStack(spacing: 0) {
                    // Modern Minimalist Header
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Theme.accent)
                                    .frame(width: 6, height: 6)
                                Text("TOTAL KEKAYAAN")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(Theme.textSecondary)
                                    .tracking(2)
                            }
                            
                            Text(CurrencyFormatter.format(totalBalance))
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            actionButton(icon: "arrow.left.and.right", color: .white.opacity(0.1)) {
                                HapticManager.shared.impact(.medium)
                                showingTransfer = true
                            }
                            
                            actionButton(icon: "plus", color: Theme.accent.opacity(0.15)) {
                                HapticManager.shared.impact(.medium)
                                showingAddWallet = true
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 20)
                    
                    // Premium Segmented Picker
                    HStack(spacing: 0) {
                        ForEach(ViewSegment.allCases, id: \.self) { segment in
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedSegment = segment
                                }
                            }) {
                                VStack(spacing: 12) {
                                    Text(segment.rawValue)
                                        .font(.system(size: 13, weight: .black))
                                        .tracking(1.5)
                                        .foregroundColor(selectedSegment == segment ? .white : Theme.textSecondary)
                                    
                                    ZStack {
                                        Capsule()
                                            .fill(Color.white.opacity(0.05))
                                            .frame(width: 60, height: 4)
                                        
                                        if selectedSegment == segment {
                                            Capsule()
                                                .fill(Theme.accent)
                                                .frame(width: 30, height: 4)
                                                .matchedGeometryEffect(id: "segment-underbar", in: segmentNamespace)
                                                .shadow(color: Theme.accent.opacity(0.5), radius: 4)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    
                    // Main Content with Swipe Support
                    TabView(selection: $selectedSegment) {
                        // WALLETS TAB
                        ScrollView(showsIndicators: false) {
                            let allRegular = wallets.filter { !$0.isGoal }
                            let mainWallet = allRegular.first { $0.name.lowercased() == "dompet utama" }
                            let otherWallets = allRegular.filter { $0.name.lowercased() != "dompet utama" }.sorted { $0.name < $1.name }
                            
                            VStack(alignment: .leading, spacing: 20) {
                                if mainWallet == nil && otherWallets.isEmpty {
                                    emptyStateView(icon: "wallet.pass.fill", message: "Belum ada dompet utama.")
                                } else {
                                    // 1. Full-width Main Wallet
                                    if let main = mainWallet {
                                        NavigationLink(destination: WalletDetailView(wallet: main)
                                            .onAppear { navigationState.isTabBarHidden = true }
                                            .onDisappear { navigationState.isTabBarHidden = false }
                                        ) {
                                            WalletVirtualCard(wallet: main, transactions: transactions)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.horizontal, 24)
                                    }
                                    
                                    // 2. 2-Column Grid for Others
                                    if !otherWallets.isEmpty {
                                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                                            ForEach(otherWallets) { wallet in
                                                NavigationLink(destination: WalletDetailView(wallet: wallet)
                                                    .onAppear { navigationState.isTabBarHidden = true }
                                                    .onDisappear { navigationState.isTabBarHidden = false }
                                                ) {
                                                    WalletVirtualCard(wallet: wallet, transactions: transactions)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.horizontal, 24)
                                    }
                                }
                                
                                Spacer(minLength: 120)
                            }
                            .padding(.top, 16)
                        }
                        .id(ViewSegment.wallets)
                        .tag(ViewSegment.wallets)
                        .refreshable { await refreshData() }
                        
                        // GOALS TAB
                        ScrollView(showsIndicators: false) {
                            let goalWallets = wallets.filter { wallet in
                                wallet.isGoal && (selectedGoalFilter == .active ? !wallet.isArchived : wallet.isArchived)
                            }
                            
                            VStack(spacing: 20) {
                                // Goal filter header
                                HStack {
                                    Text(selectedGoalFilter == .active ? "DAFTAR TARGET" : "ARSIP GOAL")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(Theme.textSecondary)
                                        .tracking(1.5)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 12) {
                                        filterButton(title: "AKTIF", filter: .active)
                                        filterButton(title: "RIWAYAT", filter: .history)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 4)
                                
                                if goalWallets.isEmpty {
                                    emptyStateView(
                                        icon: selectedGoalFilter == .active ? "target" : "archivebox.fill",
                                        message: selectedGoalFilter == .active ? "Belum ada target tabungan aktif." : "Belum ada riwayat goal."
                                    )
                                } else {
                                    ForEach(Array(goalWallets.enumerated()), id: \.element.id) { index, wallet in
                                        NavigationLink(destination: WalletDetailView(wallet: wallet)) {
                                            GoalPremiumCard(index: index, wallet: wallet, transactions: transactions)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .padding(.horizontal, 24)
                                }
                                Spacer(minLength: 120)
                            }
                        }
                        .id(ViewSegment.goals)
                        .tag(ViewSegment.goals)
                        .refreshable { await refreshData() }
                        
                        // DEBT TAB
                        ScrollView(showsIndicators: false) {
                            let unpaidDebts = debts.filter { !$0.isPaid }
                            VStack(spacing: 20) {
                                // Debt Recap Header
                                HStack(spacing: 16) {
                                    recapBox(title: "HUTANGKU", amount: debts.filter { $0.isDebt && !$0.isPaid }.reduce(0) { $0 + $1.amount }, color: Theme.expense)
                                    recapBox(title: "PINJAMANKU", amount: debts.filter { !$0.isDebt && !$0.isPaid }.reduce(0) { $0 + $1.amount }, color: Theme.income)
                                }
                                .padding(.horizontal, 24)
                                
                                Button(action: {
                                    HapticManager.shared.impact(.medium)
                                    showingDebtList = true
                                }) {
                                    HStack {
                                        Image(systemName: "list.bullet.rectangle.portrait.fill")
                                        Text("BUKA DAFTAR LENGKAP")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 18)
                                    .padding(.horizontal, 20)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(20)
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
                                }
                                .padding(.horizontal, 24)
                                
                                if unpaidDebts.isEmpty {
                                    emptyStateView(icon: "checkmark.seal.fill", message: "Semua urusan hutang sudah lunas.")
                                } else {
                                    VStack(alignment: .leading, spacing: 15) {
                                        Text("TRANSAKSI TERBARU")
                                            .font(.system(size: 10, weight: .black))
                                            .foregroundColor(Theme.textSecondary)
                                            .tracking(1.5)
                                            .padding(.horizontal, 24)
                                        
                                        // Preview of latest debts
                                        ForEach(unpaidDebts.prefix(5)) { debt in
                                            HStack(spacing: 16) {
                                                Circle()
                                                    .fill((debt.isDebt ? Theme.expense : Theme.income).opacity(0.1))
                                                    .frame(width: 40, height: 40)
                                                    .overlay(Image(systemName: debt.isDebt ? "arrow.up.right" : "arrow.down.left").font(.system(size: 12, weight: .bold)).foregroundColor(debt.isDebt ? Theme.expense : Theme.income))
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(debt.personName)
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(.white)
                                                    Text(debt.isDebt ? "Hutang ke" : "Piutang ke")
                                                        .font(.system(size: 10))
                                                        .foregroundColor(Theme.textSecondary)
                                                }
                                                Spacer()
                                                Text(CurrencyFormatter.format(debt.amount))
                                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                                    .foregroundColor(.white)
                                            }
                                            .padding(16)
                                            .background(Color.white.opacity(0.03))
                                            .cornerRadius(20)
                                            .padding(.horizontal, 24)
                                        }
                                    }
                                }
                                Spacer(minLength: 120)
                            }
                            .padding(.top, 16)
                        }
                        .id(ViewSegment.debt)
                        .tag(ViewSegment.debt)
                        .refreshable { await refreshData() }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
    }
        .sheet(isPresented: $showingAddWallet) {
            AddWalletModernSheet()
                .presentationDetents([.fraction(0.8)])
        }
        .sheet(isPresented: $showingTransfer) {
            TransferView()
                .presentationDetents([.fraction(0.8)])
        }
        .fullScreenCover(isPresented: $showingDebtList) {
            DebtListView(isPresented: $showingDebtList)
        }
        .onChange(of: showingDebtList) { old, newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                navigationState.isTabBarHidden = newValue
            }
        }
        .onAppear {
            if WalletsView.didInitialLoad {
                isLoading = false
            } else if isLoading {
                Task {
                    // Very fast shimmer for first load
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    WalletsView.didInitialLoad = true
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            isLoading = false
                        }
                    }
                }
            }
            
            Task {
                // Background Processing: Defer until view transition is complete
                try? await Task.sleep(nanoseconds: 800_000_000)
                WalletService.shared.processExpiredGoals(context: modelContext)
            }
        }
    }
    
    @Namespace private var segmentNamespace
    
    private func actionButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 46, height: 46)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(color == Theme.accent.opacity(0.15) ? Theme.accent : .white)
            }
        }
    }
    
    private func recapBox(title: String, amount: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 8, weight: .black))
                .foregroundColor(Theme.textSecondary)
                .tracking(1)
            Text(CurrencyFormatter.format(amount))
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(color.opacity(0.1))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(color.opacity(0.2), lineWidth: 1))
    }
    
    private func filterButton(title: String, filter: GoalFilter) -> some View {
        Button(action: {
            HapticManager.shared.impact(.light)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedGoalFilter = filter
            }
        }) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundColor(selectedGoalFilter == filter ? Theme.accent : Theme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(selectedGoalFilter == filter ? Theme.accent.opacity(0.1) : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(selectedGoalFilter == filter ? Theme.accent.opacity(0.2) : Color.clear, lineWidth: 1)
                )
        }
    }
    
    private func refreshData() async {
        HapticManager.shared.impact(.medium)
        WalletService.shared.processExpiredGoals(context: modelContext)
        await SyncManager.shared.processQueue(context: modelContext)
        await SyncService.shared.fetchAll(context: modelContext)
    }
    
    private func emptyStateView(icon: String, message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundColor(Theme.textSecondary.opacity(0.2))
            Text(message)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Goal Premium Card

struct GoalPremiumCard: View {
    let index: Int
    let wallet: Wallet
    let transactions: [Transaction]
    
    private var balance: Double {
        let walletTransactions = transactions.filter { $0.wallet?.id == wallet.id }
        let net = walletTransactions.reduce(0) { total, tx in
            total + (tx.isExpense ? -tx.amount : tx.amount)
        }
        return wallet.initialBalance + net
    }
    
    private var displayBalance: Double {
        wallet.isArchived ? wallet.totalSaved : balance
    }
    
    private var progress: Double {
        guard let target = wallet.targetAmount, target > 0 else { return 0 }
        return min(displayBalance / target, 1.0)
    }
    
    private var formattedDate: String? {
        guard let date = wallet.endDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: wallet.isArchived ? "checkmark.circle.fill" : "target")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(wallet.isArchived ? .green : Theme.accent)
                        
                        Text(wallet.name.uppercased())
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.white)
                            .tracking(1)
                    }
                    
                    if let dateStr = formattedDate {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 9))
                            Text(dateStr)
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(CurrencyFormatter.format(displayBalance))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            // Neon Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                    
                    Capsule()
                        .fill(Theme.accent.opacity(0.3))
                        .blur(radius: 4)
                        .frame(width: geo.size.width * CGFloat(progress))
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Theme.accent, Theme.accent.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(progress))
                }
            }
            .frame(height: 8)
            
            if let target = wallet.targetAmount {
                HStack {
                    Text("Target: \(CurrencyFormatter.format(target))")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white.opacity(0.3))
                        .tracking(0.5)
                    Spacer()
                }
            }
        }
        .padding(24)
        .background(
            ZStack {
                Theme.goalGradient(index: index)
                    .opacity(0.8)
                
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial.opacity(0.1))
                
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
        .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 10)
    }
}

// MARK: - Premium Virtual Card UI

struct WalletVirtualCard: View {
    let wallet: Wallet
    let transactions: [Transaction]
    
    private var isMainWallet: Bool {
        wallet.name.lowercased() == "dompet utama"
    }
    
    private var balance: Double {
        let walletTransactions = transactions.filter { $0.wallet?.id == wallet.id }
        let net = walletTransactions.reduce(0) { total, tx in
            total + (tx.isExpense ? -tx.amount : tx.amount)
        }
        return wallet.initialBalance + net
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    Circle()
                        .fill(isMainWallet ? Theme.goldAccent.opacity(0.2) : .white.opacity(0.12))
                        .frame(width: 42, height: 42)
                    Image(systemName: wallet.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isMainWallet ? Theme.goldAccent : .white)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white.opacity(0.2))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(wallet.name)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(CurrencyFormatter.format(balance))
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                if isMainWallet {
                    Theme.goldGradient
                        .opacity(0.9)
                } else {
                    Theme.walletGradient(for: wallet.walletType)
                        .opacity(0.8)
                }
                
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial.opacity(isMainWallet ? 0.3 : 0.2))
                
                // Animated-style glowing edge
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [
                                isMainWallet ? Theme.goldAccent.opacity(0.5) : .white.opacity(0.2), 
                                .clear, 
                                isMainWallet ? Theme.goldAccent.opacity(0.3) : Theme.walletAccent(for: wallet.walletType).opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isMainWallet ? 1.5 : 1
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: (isMainWallet ? Theme.goldAccent : Theme.walletAccent(for: wallet.walletType)).opacity(0.3), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Modern Add Wallet Sheet

struct AddWalletModernSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var name: String = ""
    @State private var selectedType: WalletType = .cash
    
    
    @State private var isGoal: Bool = false
    @State private var targetAmount: String = ""
    @State private var startDate: Date = .now
    @State private var endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
    
    @State private var animateMesh = false
    
    var body: some View {
        ZStack {
            modernBackground
            
            VStack(spacing: 0) {
                dragIndicator
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        identitySection
                        
                        if isGoal {
                            goalSettingsSection
                        } else {
                            goalToggleSection
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
                
                confirmationButton
            }
        }
    }
    
    // MARK: - Subviews
    
    private var modernBackground: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            Group {
                Circle()
                    .fill(Theme.walletAccent(for: selectedType).opacity(0.15))
                    .frame(width: 400)
                    .blur(radius: 80)
                    .offset(x: animateMesh ? 100 : -100, y: animateMesh ? -150 : 150)
                
                Circle()
                    .fill(Theme.accent.opacity(0.1))
                    .frame(width: 300)
                    .blur(radius: 100)
                    .offset(x: animateMesh ? -150 : 150, y: animateMesh ? 100 : -100)
            }
            .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animateMesh)
        }
        .ignoresSafeArea()
        .onAppear { animateMesh = true }
    }
    
    private var dragIndicator: some View {
        Capsule()
            .fill(Color.white.opacity(0.1))
            .frame(width: 40, height: 4)
            .padding(.top, 12)
    }
    
    private var identitySection: some View {
        VStack(spacing: 32) {
            minimalistInput(title: "Nama Akun", placeholder: "misal: Tabungan Nikah", text: $name)
            
            if name.localizedCaseInsensitiveCompare("Dompet Utama") == .orderedSame {
                Text("Nama ini dipesan untuk Sistem")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Theme.secondary)
                    .padding(.top, -24)
            }
            
            typeSelector
        }
        .padding(28)
        .background(glassBackground)
    }
    
    private var goalToggleSection: some View {
        Button(action: {
            HapticManager.shared.impact(.medium)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isGoal.toggle() }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("TARGET GOAL")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white.opacity(0.9))
                        .tracking(2)
                    Text("Aktifkan untuk target tabungan")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                ZStack {
                    Capsule()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 48, height: 26)
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 20, height: 20)
                        .offset(x: -11)
                }
            }
        }
        .padding(28)
        .background(glassBackground)
    }
    
    private var goalSettingsSection: some View {
        VStack(spacing: 28) {
            HStack {
                Text("PENGATURAN GOAL")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(Theme.accent)
                    .tracking(2)
                Spacer()
                Button("Batal") { withAnimation { isGoal = false } }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Theme.secondary)
            }
            
            minimalistInput(title: "Target Nominal", placeholder: "misal: 50.000.000", text: $targetAmount, isNumber: true)
            
            VStack(spacing: 24) {
                datePickerRow(title: "TANGGAL MULAI", subtitle: "Kapan Kamu mulai menabung?", selection: $startDate)
                Divider().background(Color.white.opacity(0.1))
                datePickerRow(title: "TENGGAT WAKTU", subtitle: "Kapan target harus tercapai?", selection: $endDate, range: startDate...)
            }
        }
        .padding(28)
        .background(glassBackground)
        .transition(.asymmetric(insertion: .push(from: .top).combined(with: .opacity), removal: .move(edge: .top).combined(with: .opacity)))
    }
    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 32)
            .fill(Color.white.opacity(0.03))
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
    }
    
    private func datePickerRow(title: String, subtitle: String, selection: Binding<Date>, range: PartialRangeFrom<Date>? = nil) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(.white.opacity(0.8))
                    .tracking(2)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
            if let range = range {
                DatePicker("", selection: selection, in: range, displayedComponents: .date)
                    .labelsHidden()
                    .colorInvert()
                    .colorMultiply(Theme.accent)
            } else {
                DatePicker("", selection: selection, displayedComponents: .date)
                    .labelsHidden()
                    .colorInvert()
                    .colorMultiply(Theme.accent)
            }
        }
    }
    
    private func minimalistInput(title: String, placeholder: String, text: Binding<String>, isNumber: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .black))
                .foregroundColor(.white.opacity(0.7))
                .tracking(2)
            
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.25)))
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .keyboardType(isNumber ? .numberPad : .default)
                .foregroundColor(.white)
                .padding(.bottom, 12)
                .overlay(Rectangle().frame(height: 1).foregroundColor(Color.white.opacity(0.1)), alignment: .bottom)
        }
    }
    
    private var typeSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TIPE DOMPET")
                .font(.system(size: 9, weight: .black))
                .foregroundColor(.white.opacity(0.7))
                .tracking(2)
            
            HStack(spacing: 12) {
                ForEach(WalletType.allCases, id: \.self) { type in
                    Button(action: {
                        HapticManager.shared.impact(.light)
                        selectedType = type
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: type.icon)
                                .font(.system(size: 16))
                            Text(type.rawValue.uppercased())
                                .font(.system(size: 8, weight: .black))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(selectedType == type ? Theme.walletAccent(for: type).opacity(0.25) : Color.white.opacity(0.05))
                        .foregroundColor(selectedType == type ? Theme.walletAccent(for: type) : .white.opacity(0.5))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedType == type ? Theme.walletAccent(for: type).opacity(0.4) : Color.clear, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
    
    private var confirmationButton: some View {
        Button(action: saveWallet) {
            HStack(spacing: 12) {
                Text("BUAT SEKARANG")
                Image(systemName: "arrow.right.circle.fill")
            }
            .font(.system(size: 15, weight: .black))
            .tracking(1.5)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(confirmationButtonBackground)
            .cornerRadius(24)
            .shadow(color: isButtonDisabled ? .clear : Theme.accent.opacity(0.4), radius: 20, y: 10)
        }
        .disabled(isButtonDisabled)
        .padding(24)
        .background(Color.black.opacity(0.5).background(.ultraThinMaterial).ignoresSafeArea())
    }
    
    private var isButtonDisabled: Bool {
        name.isEmpty || name.localizedCaseInsensitiveCompare("Dompet Utama") == .orderedSame
    }
    
    private var confirmationButtonBackground: some View {
        Group {
            if isButtonDisabled {
                Color.white.opacity(0.1)
            } else {
                LinearGradient(colors: [Theme.accent, Color(hex: "FFD700"), Theme.accent], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
    }
    
    private func saveWallet() {
        HapticManager.shared.notification(.success)
        let goalAmount = Double(targetAmount)
        
        let newWallet = Wallet(
            name: name, type: selectedType, initialBalance: 0.0, 
            isGoal: isGoal, targetAmount: goalAmount, 
            startDate: isGoal ? startDate : nil, endDate: isGoal ? endDate : nil
        )
        
        modelContext.insert(newWallet)
        SyncManager.shared.enqueue(endpoint: "wallets", method: .post, body: newWallet.toDTO(), context: modelContext)
        dismiss()
    }
}
