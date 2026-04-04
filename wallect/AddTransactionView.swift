import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Query var wallets: [Wallet]
    @Query var categories: [Category]
    
    // Edit Mode support
    var editTransaction: Transaction? = nil
    
    @State private var amount: String = "0"
    @State private var selectedCategory: String = "Other"
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var date: Date = .now
    @State private var isExpense: Bool = true
    @State private var selectedWallet: Wallet?
    @State private var showingCategoryManager = false
    
    @State private var appeared = false
    
    private var filteredCategories: [Category] {
        categories.filter { $0.isExpense == isExpense }
    }
    
    private var currentColor: Color {
        isExpense ? Theme.expense : Theme.income
    }
    
    var body: some View {
        ZStack {
            // Background with dynamic subtle glow
            Theme.background.ignoresSafeArea()
            
            Circle()
                .fill(currentColor.opacity(0.12))
                .blur(radius: 80)
                .frame(width: 300, height: 300)
                .offset(y: -250)
            
            VStack(spacing: 0) {
                // Header & Amount
                VStack(spacing: 12) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title3.bold())
                                .foregroundColor(Theme.textMain)
                                .frame(width: 44, height: 44)
                                .background(Theme.cardBackground.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Type Switcher (Modern Minimalist)
                        HStack(spacing: 4) {
                            Text("Pengeluaran")
                                .font(.system(size: 13, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(isExpense ? Theme.expense : Color.clear)
                                .foregroundColor(isExpense ? .black : Theme.textSecondary)
                                .cornerRadius(12)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4)) { isExpense = true }
                                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                }
                            
                            Text("Pemasukan")
                                .font(.system(size: 13, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(!isExpense ? Theme.income : Color.clear)
                                .foregroundColor(!isExpense ? .black : Theme.textSecondary)
                                .cornerRadius(12)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4)) { isExpense = false }
                                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                }
                        }
                        .padding(4)
                        .background(Theme.cardBackground.opacity(0.8))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Large Amount Display
                    VStack(spacing: 4) {
                        Text(CurrencyFormatter.formatRawString(amount))
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                            .foregroundColor(currentColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                            .contentTransition(.numericText())
                        
                        Text(isExpense ? "Total Pengeluaran" : "Total Pemasukan")
                            .font(.caption2.bold())
                            .foregroundColor(Theme.textSecondary)
                            .tracking(2)
                            .textCase(.uppercase)
                    }
                    .padding(.vertical, 20)
                }
                .padding(.bottom, 10)
                .background(
                    Theme.cardBackground.opacity(0.2)
                        .background(.ultraThinMaterial)
                        .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                )
                .clipShape(RoundedCorner(radius: 35, corners: [.bottomLeft, .bottomRight]))
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Section 1: Transaction Details
                        VStack(spacing: 12) {
                            ModernInputField(icon: "pencil", placeholder: "Untuk apa?", text: $title)
                            
                            HStack(spacing: 12) {
                                // Date Picker (Minimal)
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(currentColor)
                                    DatePicker("", selection: $date, displayedComponents: .date)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 54)
                                .background(Theme.cardBackground.opacity(0.5))
                                .cornerRadius(16)
                                
                                // Category Manager Trigger
                                ModernInputField(icon: "note.text", placeholder: "Catatan...", text: $notes)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Section 2: Wallet Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Dompet Pembayaran")
                                .font(.caption.bold())
                                .foregroundColor(Theme.textSecondary)
                                .padding(.horizontal, 25)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(wallets) { wallet in
                                        WalletGlassCard(wallet: wallet, isSelected: selectedWallet == wallet) {
                                            selectedWallet = wallet
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Section 3: Categories
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Kategori")
                                    .font(.caption.bold())
                                    .foregroundColor(Theme.textSecondary)
                                Spacer()
                                Button(action: { showingCategoryManager = true }) {
                                    Text("Kelola")
                                        .font(.caption2.bold())
                                        .foregroundColor(Theme.accent)
                                }
                            }
                            .padding(.horizontal, 25)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(filteredCategories) { cat in
                                        CategoryGlassItem(title: cat.name, icon: cat.icon, isSelected: selectedCategory == cat.name, accentColor: currentColor) {
                                            selectedCategory = cat.name
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Section 4: Keypad (Integrated more cleanly)
                        VStack(spacing: 15) {
                            ModernKeypad(amount: $amount, accentColor: currentColor)
                            
                            // Save Button
                            Button(action: saveTransaction) {
                                Text(editTransaction == nil ? "Tambah Transaksi" : "Simpan Perubahan")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(currentColor)
                                    .cornerRadius(18)
                                    .shadow(color: currentColor.opacity(0.35), radius: 15, x: 0, y: 8)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                            .disabled(amount == "0" || title.isEmpty || selectedWallet == nil)
                            .opacity((amount == "0" || title.isEmpty || selectedWallet == nil) ? 0.3 : 1)
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
        .sheet(isPresented: $showingCategoryManager) {
            CategoryManagerView()
        }
        .onAppear {
            setupForEdit()
            ensureDefaultWallet()
            ensureDefaultCategories()
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }
    
    // Core Logics (Same as before but linked to UI)
    private func ensureDefaultCategories() {
        if categories.isEmpty {
            let defaults = [
                Category(name: "Food", icon: "fork.knife", isExpense: true),
                Category(name: "Shopping", icon: "cart.fill", isExpense: true),
                Category(name: "Transport", icon: "car.fill", isExpense: true),
                Category(name: "Work", icon: "briefcase.fill", isExpense: false),
                Category(name: "Gift", icon: "gift.fill", isExpense: false),
                Category(name: "Other", icon: "dollarsign.circle", isExpense: true)
            ]
            for cat in defaults { modelContext.insert(cat) }
        }
        if selectedCategory == "Other" && !filteredCategories.isEmpty {
             if let first = filteredCategories.first { selectedCategory = first.name }
        }
    }
    
    private func ensureDefaultWallet() {
        if wallets.isEmpty {
            let defaultWallet = Wallet(name: "Dompet Utama", type: .cash, initialBalance: 0)
            WalletService.shared.createWallet(defaultWallet, context: modelContext)
            selectedWallet = defaultWallet
        } else if selectedWallet == nil {
            selectedWallet = wallets.first
        }
    }
    
    private func setupForEdit() {
        if let transaction = editTransaction {
            title = transaction.title
            amount = String(Int(transaction.amount))
            selectedCategory = transaction.category
            notes = transaction.note
            date = transaction.date
            isExpense = transaction.isExpense
            selectedWallet = transaction.wallet
        }
    }
    
    private func saveTransaction() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        let finalAmount = CurrencyFormatter.toDouble(amount)
        if let transaction = editTransaction {
            transaction.title = title
            transaction.amount = finalAmount
            transaction.category = selectedCategory
            transaction.note = notes
            transaction.date = date
            transaction.isExpense = isExpense
            transaction.wallet = selectedWallet
            TransactionService.shared.updateTransaction(transaction, context: modelContext)
        } else {
            let newTransaction = Transaction(
                title: title, amount: finalAmount, category: selectedCategory,
                date: date, note: notes, isExpense: isExpense, wallet: selectedWallet
            )
            TransactionService.shared.createTransaction(newTransaction, context: modelContext)
        }
        dismiss()
    }
}

// MARK: - Reusable Components (Refined)

struct ModernInputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Theme.accent.opacity(0.7))
                .frame(width: 20)
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(Theme.cardBackground.opacity(0.5))
        .cornerRadius(16)
    }
}

struct WalletGlassCard: View {
    let wallet: Wallet
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: wallet.icon)
                    .font(.system(size: 12, weight: .bold))
                Text(wallet.name)
                    .font(.system(size: 13, weight: .bold))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(isSelected ? Theme.accent : Theme.cardBackground.opacity(0.3))
            .foregroundColor(isSelected ? .black : Theme.textSecondary)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Theme.accent.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

struct CategoryGlassItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? accentColor : Theme.cardBackground.opacity(0.4))
                        .frame(width: 54, height: 54)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isSelected ? .black : Theme.textSecondary)
                }
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? accentColor : Theme.textSecondary)
            }
        }
    }
}

// RoundedCorner helper for top layout
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ModernKeypad: View {
    @Binding var amount: String
    let accentColor: Color
    
    let buttons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["000", "0", "delete.left"]
    ]
    
    var body: some View {
        VStack(spacing: 14) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 14) {
                    ForEach(row, id: \.self) { button in
                        Button(action: { handleInput(button) }) {
                            Group {
                                if button == "delete.left" {
                                    Image(systemName: button)
                                        .font(.system(size: 20, weight: .medium))
                                } else {
                                    Text(button)
                                        .font(.system(size: 22, weight: .medium, design: .rounded))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Theme.cardBackground.opacity(0.3))
                            .cornerRadius(14)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 25)
    }
    
    private func handleInput(_ symbol: String) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if symbol == "delete.left" {
            if amount.count > 1 { amount.removeLast() } else { amount = "0" }
        } else if symbol == "000" {
            if amount != "0" && amount.count < 9 { amount += "000" }
        } else {
            if amount == "0" { amount = symbol }
            else if amount.count < 11 { amount += symbol }
        }
    }
}

#Preview {
    AddTransactionView()
}
