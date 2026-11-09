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
    @State private var showingDeleteAlert = false
    
    @State private var appeared = false
    
    private var filteredCategories: [Category] {
        categories.filter { $0.isExpense == isExpense }
    }
    
    private var currentColor: Color {
        if let cat = categories.first(where: { $0.name == selectedCategory }) {
            return Color(hex: cat.hexColor)
        }
        return isExpense ? Theme.expense : Theme.income
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            // Dynamic Glow Blobs (Synced with category)
            ZStack {
                Circle()
                    .fill(currentColor.opacity(0.12))
                    .frame(width: 400, height: 400)
                    .blur(radius: 80)
                    .offset(x: -150, y: -200)
                
                Circle()
                    .fill(currentColor.opacity(0.08))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: 100, y: 150)
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: selectedCategory)
            
            VStack(spacing: 0) {
                // Header & "Digital Receipt" Section
                VStack(spacing: 16) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.05))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Transaction Type Indicator
                        HStack(spacing: 8) {
                            Text(isExpense ? "PENGELUARAN" : "PEMASUKAN")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.white.opacity(0.6))
                                .tracking(1.5)
                            
                            if editTransaction != nil {
                                Circle()
                                    .fill(Theme.accent)
                                    .frame(width: 4, height: 4)
                                Text("VIRTUAL RECEIPT")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(Theme.accent)
                                    .tracking(1)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // Large Receipt Card
                    ZStack {
                        // Background Faded Icon
                        if let cat = categories.first(where: { $0.name == selectedCategory }) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 80))
                                .foregroundColor(currentColor.opacity(0.05))
                                .offset(x: 100, y: -20)
                        }
                        
                        VStack(spacing: 6) {
                            Text(CurrencyFormatter.formatRawString(amount))
                                .font(.system(size: 38, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .monospacedDigit()
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                            
                            HStack(spacing: 6) {
                                if editTransaction?.syncStatus == "synced" {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(Theme.accent)
                                }
                                Text(editTransaction == nil ? "TRANSAKSI BARU" : "DETAIL TRANSAKSI")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(Theme.textSecondary)
                                    .tracking(1.5)
                            }
                        }
                    }
                    .padding(.vertical, 30)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            Color.white.opacity(0.02)
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(
                                    LinearGradient(colors: [.white.opacity(0.15), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 1
                                )
                        }
                    )
                    .cornerRadius(32)
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Section: Category Selection
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("PILIH KATEGORI")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(Theme.textSecondary)
                                    .tracking(1.5)
                                Spacer()
                                
                                // Income/Expense Toggle (Compact)
                                HStack(spacing: 0) {
                                    Button(action: { withAnimation { isExpense = true } }) {
                                        Image(systemName: "minus")
                                            .font(.system(size: 10, weight: .black))
                                            .frame(width: 28, height: 28)
                                            .background(isExpense ? Theme.expense : Color.white.opacity(0.05))
                                            .foregroundColor(isExpense ? .black : .white)
                                    }
                                    
                                    Button(action: { withAnimation { isExpense = false } }) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 10, weight: .black))
                                            .frame(width: 28, height: 28)
                                            .background(!isExpense ? Theme.income : Color.white.opacity(0.05))
                                            .foregroundColor(!isExpense ? .black : .white)
                                    }
                                }
                                .cornerRadius(8)
                            }
                            .padding(.horizontal, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(filteredCategories) { cat in
                                        Button(action: {
                                            selectedCategory = cat.name
                                            HapticManager.shared.impact(.light)
                                        }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: cat.icon)
                                                    .font(.system(size: 12))
                                                Text(cat.name)
                                                    .font(.system(size: 12, weight: .bold))
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(selectedCategory == cat.name ? currentColor : Color.white.opacity(0.05))
                                            .foregroundColor(selectedCategory == cat.name ? .black : .white)
                                            .cornerRadius(14)
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        // Section: Form Details
                        VStack(spacing: 20) {
                            receiptField(title: "Judul Transaksi", icon: "pencil", value: $title, placeholder: isExpense ? "Beli apa?" : "Dari mana?")
                            
                            HStack(spacing: 16) {
                                // Wallet Selection
                                Menu {
                                    ForEach(wallets.filter { !$0.isArchived && !$0.isGoal }) { wallet in
                                        Button(action: { selectedWallet = wallet }) {
                                            Label(wallet.name, systemImage: wallet.icon)
                                        }
                                    }
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("DOMPET")
                                            .font(.system(size: 9, weight: .black))
                                            .foregroundColor(Theme.textSecondary)
                                        HStack {
                                            Image(systemName: selectedWallet?.icon ?? "wallet.pass")
                                                .foregroundColor(Theme.accent)
                                            Text(selectedWallet?.name ?? "Pilih...")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color.white.opacity(0.02))
                                        .cornerRadius(16)
                                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
                                    }
                                }
                                
                                // Date Selection
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("TANGGAL")
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundColor(Theme.textSecondary)
                                    DatePicker("", selection: $date, displayedComponents: .date)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                        .padding(.vertical, 4)
                                        .background(Color.white.opacity(0.02))
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white.opacity(0.02))
                                        .cornerRadius(16)
                                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
                                }
                            }
                            
                            receiptField(title: "Catatan Tambahan", icon: "note.text", value: $notes, placeholder: "Tulis catatan di sini...")
                        }
                        .padding(.horizontal, 24)
                        
                        // Keypad (Modern Minimalist)
                        ModernKeypad(amount: $amount, accentColor: currentColor)
                            .padding(.top, 10)
                        
                        // Actions Footer
                        VStack(spacing: 12) {
                            Button(action: saveTransaction) {
                                Text(editTransaction == nil ? "KONFIRMASI" : "SIMPAN PERUBAHAN")
                                    .font(.system(size: 16, weight: .black))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(amount == "0" || title.isEmpty ? Color.white.opacity(0.1) : currentColor)
                                    .cornerRadius(20)
                                    .shadow(color: currentColor.opacity(0.2), radius: 15)
                            }
                            .disabled(amount == "0" || title.isEmpty)
                            
                            if editTransaction != nil {
                                Button(action: { showingDeleteAlert = true }) {
                                    Text("Hapus Transaksi")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.red.opacity(0.8))
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(24)
                    }
                }
            }
        }
        .alert("Hapus Transaksi?", isPresented: $showingDeleteAlert) {
            Button("Batal", role: .cancel) { }
            Button("Hapus", role: .destructive) { deleteTransaction() }
        } message: {
            Text("Data ini akan dihapus secara permanen dari akun Kamu.")
        }
        .onAppear {
            setupForEdit()
            ensureDefaultWallet()
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }
    
    private func receiptField(title: String, icon: String, value: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .black))
                .foregroundColor(Theme.textSecondary)
                .tracking(1.5)
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(currentColor.opacity(0.7))
                TextField(placeholder, text: value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.white.opacity(0.02))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
        }
    }
    
    private func ensureDefaultWallet() {
        if selectedWallet == nil {
            if let first = wallets.first {
                selectedWallet = first
            }
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
        if isExpense {
            HapticManager.shared.impact(.heavy)
        } else {
            HapticManager.shared.notification(.success)
        }
        
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
    
    private func deleteTransaction() {
        if let transaction = editTransaction {
            let id = transaction.id
            modelContext.delete(transaction)
            SyncManager.shared.enqueue(endpoint: "transactions/\(id)", method: .delete, context: modelContext)
            dismiss()
        }
    }
}

// MARK: - Reusable Components (Refined)

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
        VStack(spacing: 12) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { button in
                        Button(action: { handleInput(button) }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.white.opacity(0.04), lineWidth: 1)
                                    )
                                
                                Group {
                                    if button == "delete.left" {
                                        Image(systemName: button)
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white.opacity(0.6))
                                    } else {
                                        Text(button)
                                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 40)
    }
    
    private func handleInput(_ symbol: String) {
        HapticManager.shared.impact(.light)
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
