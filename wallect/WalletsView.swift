import SwiftUI
import SwiftData

struct WalletsView: View {
    @Environment(\.modelContext) var modelContext
    @Query var wallets: [Wallet]
    @Query var transactions: [Transaction]
    @State private var showingAddWallet = false
    @State private var appeared = false
    
    private var totalBalance: Double {
        let walletsInitial = wallets.reduce(0) { $0 + $1.initialBalance }
        let transactionsNet = transactions.reduce(0) { total, tx in
            total + (tx.isExpense ? -tx.amount : tx.amount)
        }
        return walletsInitial + transactionsNet
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Kekayaan")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                            Text(CurrencyFormatter.format(totalBalance))
                                .font(.title.bold())
                                .foregroundColor(Theme.textMain)
                        }
                        Spacer()
                        Button(action: { showingAddWallet = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(Theme.accent)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -10)
                    
                    // Wallet Grid
                    if wallets.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "wallet.pass.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Theme.textSecondary.opacity(0.3))
                                .padding(.top, 50)
                            Text("Belum ada dompet terdaftar.")
                                .foregroundColor(Theme.textSecondary)
                        }
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(wallets) { wallet in
                                WalletGridCard(wallet: wallet, transactions: transactions)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Detailed Breakdown Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Rincian Akun")
                            .font(.headline)
                            .foregroundColor(Theme.textMain)
                            .padding(.horizontal)
                        
                        ForEach(wallets) { wallet in
                            WalletListRow(wallet: wallet, transactions: transactions)
                        }
                    }
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 120)
                }
            }
        }
        .sheet(isPresented: $showingAddWallet) {
            AddWalletView()
                .presentationDetents([.fraction(0.6)])
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
}

struct WalletGridCard: View {
    let wallet: Wallet
    let transactions: [Transaction]
    
    private var balance: Double {
        let walletTransactions = transactions.filter { $0.wallet?.id == wallet.id }
        let net = walletTransactions.reduce(0) { total, tx in
            total + (tx.isExpense ? -tx.amount : tx.amount)
        }
        return wallet.initialBalance + net
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: wallet.icon)
                    .font(.title2)
                    .foregroundColor(Theme.walletAccent(for: wallet.walletType))
                Spacer()
                Text(wallet.walletType.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.accent.opacity(0.1))
                    .foregroundColor(Theme.accent)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(wallet.name)
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.textMain)
                Text(CurrencyFormatter.format(balance))
                    .font(.headline)
                    .foregroundColor(Theme.textMain)
            }
        }
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.cardBackground.opacity(0.4))
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.walletGradient(for: wallet.walletType))
                    .opacity(0.15)
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Theme.walletAccent(for: wallet.walletType).opacity(0.2), lineWidth: 1)
            }
        )
    }
}

struct WalletListRow: View {
    @Environment(\.modelContext) var modelContext
    let wallet: Wallet
    let transactions: [Transaction]
    
    private var balance: Double {
        let walletTransactions = transactions.filter { $0.wallet?.id == wallet.id }
        let net = walletTransactions.reduce(0) { total, tx in
            total + (tx.isExpense ? -tx.amount : tx.amount)
        }
        return wallet.initialBalance + net
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(Theme.cardBackground)
                .frame(width: 45, height: 45)
                .overlay(
                    Image(systemName: wallet.icon)
                        .foregroundColor(Theme.accent)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(wallet.name)
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.textMain)
                Text(wallet.walletType.rawValue)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
            
            Text(CurrencyFormatter.format(balance))
                .font(.subheadline.bold())
                .foregroundColor(Theme.textMain)
        }
        .padding()
        .background(Theme.cardBackground.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
        .contextMenu {
            Button(role: .destructive) {
                let walletId = wallet.id
                modelContext.delete(wallet)
                SyncManager.shared.enqueue(endpoint: "wallets/\(walletId)", method: .delete, context: modelContext)
            } label: {
                Label("Hapus Dompet", systemImage: "trash")
            }
        }
    }
}

struct AddWalletView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var name: String = ""
    @State private var selectedType: WalletType = .cash
    @State private var initialBalance: String = "0"
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header & Drag Indicator
                VStack(spacing: 15) {
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 44, height: 5)
                    
                    Text("Tambah Dompet Baru")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textMain)
                }
                .padding(.top, 25) // Significant padding top
                
                VStack(spacing: 24) {
                    // Name Input
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Nama Dompet", systemImage: "pencil")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.textSecondary)
                        
                        TextField("Contoh: BCA, OVO, Tunai", text: $name)
                            .font(.system(size: 16, weight: .medium))
                            .padding()
                            .background(Theme.cardBackground.opacity(0.6))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .foregroundColor(.white)
                    }
                    
                    // Wallet Type Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Tipe Akun", systemImage: "list.bullet.indent")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.textSecondary)
                        
                        HStack(spacing: 12) {
                            ForEach(WalletType.allCases, id: \.self) { type in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedType = type
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: type.icon)
                                            .font(.system(size: 16))
                                        Text(type.rawValue)
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(selectedType == type ? Theme.accent : Theme.cardBackground.opacity(0.4))
                                    .foregroundColor(selectedType == type ? .black : Theme.textSecondary)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedType == type ? Theme.accent : Color.white.opacity(0.05), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    
                    // Initial Balance Input
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Saldo Awal", systemImage: "dollarsign.circle")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.textSecondary)
                        
                        HStack {
                            Text("Rp")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Theme.accent)
                            TextField("0", text: $initialBalance)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .keyboardType(.numberPad)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Theme.cardBackground.opacity(0.6))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Premium Save Button
                Button(action: saveWallet) {
                    Text("Simpan Dompet")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            ZStack {
                                if !name.isEmpty {
                                    Theme.mainGradient
                                } else {
                                    Color.white.opacity(0.1)
                                }
                            }
                        )
                        .cornerRadius(20)
                        .shadow(color: !name.isEmpty ? Theme.accent.opacity(0.3) : Color.clear, radius: 15, x: 0, y: 8)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .disabled(name.isEmpty)
            }
        }
    }
    
    private func saveWallet() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let balance = Double(initialBalance) ?? 0
        let newWallet = Wallet(name: name, type: selectedType, initialBalance: balance)
        modelContext.insert(newWallet)
        SyncManager.shared.enqueue(endpoint: "wallets", method: .post, body: newWallet.toDTO(), context: modelContext)
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Wallet.self, Transaction.self, configurations: config)
    WalletsView()
        .modelContainer(container)
}
