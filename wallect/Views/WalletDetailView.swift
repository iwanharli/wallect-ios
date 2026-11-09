#if !WIDGET_EXTENSION
import SwiftUI
import SwiftData

struct WalletDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Bindable var wallet: Wallet
    
    @Query(sort: \Transaction.date, order: .reverse) var allTransactions: [Transaction]
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var editedName: String = ""
    @State private var editedInitialBalance: String = ""
    @State private var selectedType: WalletType = .cash
    @State private var showingTransfer = false
    @State private var animateMesh = false
    
    var walletTransactions: [Transaction] {
        allTransactions.filter { $0.wallet?.id == wallet.id }
    }
    
    var currentBalance: Double {
        let transactionTotal = walletTransactions.reduce(0) { sum, tx in
            sum + (tx.isExpense ? -tx.amount : tx.amount)
        }
        return wallet.initialBalance + transactionTotal
    }
    
    private var isMainWallet: Bool {
        wallet.name.localizedCaseInsensitiveCompare("Dompet Utama") == .orderedSame
    }
    
    var body: some View {
        ZStack {
            Theme.DynamicBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    // Minimalist Wallet Header Card
                    VStack(spacing: 18) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Theme.mainGradient.opacity(0.12))
                                    .frame(width: 54, height: 54)
                                
                                Image(systemName: wallet.walletType.icon)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(Theme.mainGradient)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(wallet.name)
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundColor(Theme.textMain)
                                
                                Text(wallet.walletType.rawValue.uppercased())
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundColor(Theme.textSecondary)
                                    .tracking(1.5)
                            }
                            
                            Spacer()
                            
                            // ALLOCATION BUTTON FOR ACTIVE GOALS
                            if wallet.isGoal && !wallet.isArchived {
                                Button(action: { 
                                    HapticManager.shared.impact(.medium)
                                    showingTransfer = true 
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(Theme.accent)
                                }
                            }
                        }
                        
                        Divider().background(Color.white.opacity(0.05))
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SALDO SAAT INI")
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundColor(Theme.textSecondary)
                                    .tracking(1.5)
                                
                                Text(CurrencyFormatter.format(currentBalance))
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                    .foregroundColor(Theme.textMain)
                            }
                            Spacer()
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Theme.cardBackground.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    
                    // Goal Analytics Section
                    if wallet.isGoal {
                        goalAnalyticsSection
                            .padding(.horizontal)
                        
                        dateRangeSection
                            .padding(.horizontal)
                    }
                    
                    // Transaction History Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("RIWAYAT TRANSAKSI")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(Theme.textSecondary)
                                .tracking(1.5)
                            
                            Spacer()
                            
                            Text("\(walletTransactions.count) Transaksi")
                                .font(.caption.bold())
                                .foregroundColor(Theme.accent)
                        }
                        .padding(.horizontal)
                        
                        if walletTransactions.isEmpty {
                            VStack(spacing: 15) {
                                Image(systemName: "tray.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Theme.textSecondary.opacity(0.3))
                                Text("Belum ada transaksi di dompet ini")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 50)
                            .background(Theme.cardBackground.opacity(0.2))
                            .cornerRadius(24)
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(walletTransactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !isMainWallet {
                    Menu {
                        if !wallet.isGoal {
                            Button {
                                setupEdit()
                                showingEditSheet = true
                            } label: {
                                Label("Edit Dompet", systemImage: "pencil")
                            }
                        }
                        
                        if !isMainWallet {
                            Button(role: .destructive) {
                                showingDeleteAlert = true
                            } label: {
                                Label(wallet.isGoal ? "Hapus Goal" : "Hapus Dompet", systemImage: "trash")
                            }
                        }
                        
                        if wallet.isGoal && !wallet.isArchived {
                            Button {
                                archiveGoal()
                            } label: {
                                Label("Arsipkan Goal", systemImage: "archivebox.fill")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundColor(Theme.textMain)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            ZStack {
                modernBackground
                
                VStack(spacing: 0) {
                    dragIndicator
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 32) {
                            // Header Title
                            VStack(spacing: 8) {
                                Text("EDIT DOMPET")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(Theme.accent)
                                    .tracking(2.5)
                                
                                Text(wallet.name.uppercased())
                                    .font(.system(size: 16, weight: .black))
                                    .foregroundColor(.white.opacity(0.3))
                                    .tracking(1)
                            }
                            .padding(.top, 24)
                            
                            // Form Card
                            VStack(spacing: 32) {
                                minimalistInput(title: "Nama Akun", placeholder: "misal: Tabungan Nikah", text: $editedName)
                                
                                typeSelector
                                
                                minimalistInput(title: "Saldo Awal", placeholder: "0", text: $editedInitialBalance, isNumber: true)
                                    .opacity(isMainWallet ? 0.3 : 1.0)
                                    .disabled(isMainWallet)
                                
                                if isMainWallet {
                                    Text("Saldo awal Dompet Utama tidak dapat diubah")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(Theme.textSecondary)
                                        .padding(.top, -24)
                                }
                            }
                            .padding(28)
                            .background(glassBackground)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    confirmationButton
                }
            }
            .presentationDetents([.fraction(0.85)])
        }
        .alert(wallet.isGoal ? "Hapus Goal" : "Hapus Dompet", isPresented: $showingDeleteAlert) {
            Button("Batal", role: .cancel) { }
            Button("Hapus", role: .destructive) {
                deleteWallet()
            }
        } message: {
            if currentBalance > 0 {
                Text("Apakah Kamu yakin? Sisa saldo sebesar \(CurrencyFormatter.format(currentBalance)) akan dikembalikan ke Dompet Utama. Seluruh riwayat transaksi di \(wallet.isGoal ? "goal" : "dompet") ini akan dihapus.")
            } else {
                Text("Apakah Kamu yakin ingin menghapus \(wallet.isGoal ? "goal" : "dompet") ini? Seluruh riwayat transaksi di \(wallet.isGoal ? "goal" : "dompet") ini akan dihapus.")
            }
        }
        .sheet(isPresented: $showingTransfer) {
            TransferView(initialDestination: wallet)
                .presentationDetents([.fraction(0.85)])
        }
    }
    
    private func setupEdit() {
        editedName = wallet.name
        editedInitialBalance = String(wallet.initialBalance)
        selectedType = wallet.walletType
    }
    
    private func saveChanges() {
        wallet.name = editedName
        wallet.type = selectedType.rawValue
        wallet.icon = selectedType.icon
        if let balance = Double(editedInitialBalance) {
            wallet.initialBalance = balance
        }
        
        // Use service to sync update
        WalletService.shared.updateWallet(wallet, context: modelContext)
    }
    
    private func deleteWallet() {
        // Use service to sync deletion and handle balance reversal
        WalletService.shared.deleteWallet(wallet, currentBalance: currentBalance, context: modelContext)
        dismiss()
    }
    
    private func archiveGoal() {
        HapticManager.shared.impact(.medium)
        wallet.isArchived = true
        // Sync the update
        WalletService.shared.updateWallet(wallet, context: modelContext)
        dismiss()
    }
    
    private var goalAnalyticsSection: some View {
        let progress = wallet.targetAmount ?? 0 > 0 ? min(wallet.currentBalance / (wallet.targetAmount ?? 1), 1) : 0
        let remaining = max((wallet.targetAmount ?? 0) - wallet.currentBalance, 0)
        
        return VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PROGRES TARGET")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Theme.textSecondary)
                        .tracking(1.5)
                    Text("\(Int(progress * 100))% Tercapai")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
                
                if progress >= 1.0 {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundColor(Theme.income)
                }
            }
            
            // Large Neon Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                    
                    // Glow Layer
                    Capsule()
                        .fill(Theme.accent.opacity(0.3))
                        .blur(radius: 4)
                        .frame(width: geo.size.width * CGFloat(progress))
                    
                    // Main Bar
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Theme.accent, Theme.accent.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(progress))
                }
            }
            .frame(height: 12)
            
            // Stats Grid
            HStack(spacing: 0) {
                statDetail(label: "TERKUMPUL", value: wallet.currentBalance, color: .white)
                divider
                statDetail(label: "TARGET", value: wallet.targetAmount ?? 0, color: .white.opacity(0.6))
                divider
                statDetail(label: "SISA", value: remaining, color: Theme.accent)
            }
            .padding(.top, 10)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Theme.cardBackground.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("TIMELINE TARGET")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(Theme.textSecondary)
                .tracking(1.5)
            
            HStack(spacing: 20) {
                dateBadge(label: "MULAI", date: wallet.startDate)
                
                Image(systemName: "arrow.right")
                    .font(.caption.bold())
                    .foregroundColor(Theme.textSecondary.opacity(0.3))
                
                dateBadge(label: "DEADLINE", date: wallet.endDate)
            }
            
            if let endDate = wallet.endDate {
                let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
                
                HStack {
                    Image(systemName: "clock.badge.checkmark.fill")
                        .foregroundColor(daysLeft >= 0 ? Theme.accent : .red)
                    Text(daysLeft >= 0 ? "\(daysLeft) Hari Lagi" : "Terlewati \(abs(daysLeft)) Hari")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(daysLeft >= 0 ? .white : .red.opacity(0.8))
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Theme.cardBackground.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
    
    private func statDetail(label: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .black))
                .foregroundColor(Theme.textSecondary)
            NominalText(amount: value, size: 14, color: color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(width: 1, height: 30)
            .padding(.horizontal, 10)
    }
    
    private func dateBadge(label: String, date: Date?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .black))
                .foregroundColor(Theme.textSecondary)
            
            if let date = date {
                Text(formatDetailDate(date))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            } else {
                Text("-")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Theme.textSecondary.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func formatDetailDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }
    
    // MARK: - Modern UI Helper Views
    
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
    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 32)
            .fill(Color.white.opacity(0.03))
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
    }
    
    private func minimalistInput(title: String, placeholder: String, text: Binding<String>, isNumber: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .black))
                .foregroundColor(Theme.textSecondary)
                .tracking(2)
            
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.2)))
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
                .foregroundColor(Theme.textSecondary)
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
                        .background(selectedType == type ? Theme.walletAccent(for: type).opacity(0.2) : Color.white.opacity(0.05))
                        .foregroundColor(selectedType == type ? Theme.walletAccent(for: type) : .white.opacity(0.4))
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
        Button(action: {
            saveChanges()
            showingEditSheet = false
        }) {
            HStack(spacing: 12) {
                Text("SIMPAN PERUBAHAN")
                Image(systemName: "checkmark.circle.fill")
            }
            .font(.system(size: 15, weight: .black))
            .tracking(1.5)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(
                LinearGradient(colors: [Theme.accent, Color(hex: "FFD700")], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(24)
            .shadow(color: Theme.accent.opacity(0.4), radius: 20, y: 10)
        }
        .padding(24)
        .background(Color.black.opacity(0.5).background(.ultraThinMaterial).ignoresSafeArea())
    }

}

#endif
