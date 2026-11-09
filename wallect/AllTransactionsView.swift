#if !WIDGET_EXTENSION
import SwiftUI
import SwiftData

struct AllTransactionsView: View {
    @Binding var isPresented: Bool
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]
    @Query var allCategories: [Category]
    var initialType: String = "Semua"
    
    // Filtering States
    @State private var searchText: String = ""
    @State private var selectedType: String = "Semua"
    @State private var selectedCategory: String = "Semua"
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now
    @State private var filterByDate: Bool = false
    @State private var showingDateRangePicker = false
    @State private var showingEditTransaction: Transaction? = nil
    
    @State private var appeared = false
    
    private let types = ["Semua", "Pemasukan", "Pengeluaran", "By Sistem"]
    
    private var groupedTransactions: [(Date, [Transaction])] {
        let calendar = Calendar.current
        let filtered = transactions.filter { transaction in
            // Basic Filters
            let matchesSearch = searchText.isEmpty || 
                                transaction.title.localizedCaseInsensitiveContains(searchText) || 
                                transaction.note.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == "Semua" || transaction.category == selectedCategory
            
            let start = calendar.startOfDay(for: startDate)
            let end = calendar.startOfDay(for: endDate).addingTimeInterval(86399)
            let matchesDate = !filterByDate || (transaction.date >= start && transaction.date <= end)
            
            // Type & System Logic
            let matchesType: Bool = {
                switch selectedType {
                case "Semua":
                    return !transaction.isSystem // Standard view excludes system
                case "Pemasukan":
                    return !transaction.isExpense && !transaction.isSystem
                case "Pengeluaran":
                    return transaction.isExpense && !transaction.isSystem
                case "By Sistem":
                    return transaction.isSystem // Explicitly show ONLY system
                default:
                    return true
                }
            }()
            
            return matchesSearch && matchesType && matchesCategory && matchesDate
        }
        
        let grouped = Dictionary(grouping: filtered) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
        
        return grouped.sorted { $0.key > $1.key }
    }
    
    private var headerTotals: (income: Double, expense: Double) {
        // SUMMARY SHOULD ONLY COUNT MANUAL TRANSACTIONS
        let manualTransactions = transactions.filter { !$0.isSystem }
        
        let calendar = Calendar.current
        let filtered = manualTransactions.filter { transaction in
            let matchesCategory = selectedCategory == "Semua" || transaction.category == selectedCategory
            let start = calendar.startOfDay(for: startDate)
            let end = calendar.startOfDay(for: endDate).addingTimeInterval(86399)
            let matchesDate = !filterByDate || (transaction.date >= start && transaction.date <= end)
            return matchesCategory && matchesDate
        }
        
        let income = filtered.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
        let expense = filtered.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
        return (income, expense)
    }
    
    var body: some View {
        ZStack {
            Theme.DynamicBackground()
            
            VStack(spacing: 0) {
                // Tactical Header
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daftar Transaksi")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(Theme.accent.opacity(0.8))
                            .tracking(2)
                        Text("Riwayat")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 8)
                    
                    Spacer()
                    
                    if filterByDate || selectedType != "Semua" || selectedCategory != "Semua" || !searchText.isEmpty {
                        Button(action: resetFilters) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Theme.accent)
                                .clipShape(Circle())
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                // Modern Summary Card
                HistorySummaryCard(income: headerTotals.income, expense: headerTotals.expense)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                
                // Content Filter Section
                VStack(spacing: 20) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(Theme.textSecondary)
                        TextField("Cari transaksi...", text: $searchText)
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 54)
                    .background(Color.white.opacity(0.04))
                    .background(.ultraThinMaterial.opacity(0.1))
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.glassBorder, lineWidth: 1))
                    .padding(.horizontal, 24)
                    
                    // Filter Chips - Row 1: Types
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(types, id: \.self) { type in
                                FilterChipPremium(
                                    title: type, 
                                    icon: getTypeIcon(type), 
                                    isSelected: selectedType == type
                                ) {
                                    selectedType = type
                                    HapticManager.shared.impact(.light)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Filter Chips - Row 2: Parameters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            // Date Range Chip
                            FilterChipPremium(
                                title: filterByDate ? "\(formatDate(startDate)) - \(formatDate(endDate))" : "Rentang Waktu",
                                icon: "calendar",
                                isSelected: filterByDate
                            ) {
                                showingDateRangePicker = true
                                HapticManager.shared.impact(.light)
                            }
                            .popover(isPresented: $showingDateRangePicker) {
                                dateRangePickerView
                                    .presentationCompactAdaptation(.popover)
                            }
                            
                            // Category Menu
                            Menu {
                                Button("Semua Kategori") { selectedCategory = "Semua" }
                                Divider()
                                ForEach(allCategories) { cat in
                                    Button(action: { selectedCategory = cat.name }) {
                                        Label(cat.name, systemImage: cat.icon)
                                    }
                                }
                            } label: {
                                FilterChipPremium(
                                    title: selectedCategory == "Semua" ? "Kategori" : selectedCategory,
                                    icon: "tag.fill",
                                    isSelected: selectedCategory != "Semua"
                                ) { }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 16)
                
                // Transaction List
                if groupedTransactions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.textSecondary.opacity(0.2))
                        Text(selectedType == "By Sistem" ? "Tidak ada alokasi sistem" : "Tidak ada transaksi ditemukan")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 100)
                } else {
                    List {
                        ForEach(groupedTransactions, id: \.0) { date, items in
                            Section {
                                ForEach(items) { transaction in
                                    TransactionRow(transaction: transaction)
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24))
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
                                                    Label("Hapus", systemImage: "trash.fill")
                                                }
                                            }
                                        }
                                }
                            } header: {
                                HStack(spacing: 8) {
                                    Text(headerDate(date))
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Theme.accent.opacity(0.15))
                                        .cornerRadius(8)
                                    
                                    Spacer()
                                    
                                    if selectedType != "By Sistem" {
                                        let dayTotal = items.reduce(0) { total, tx in
                                            total + (tx.isExpense ? -tx.amount : tx.amount)
                                        }
                                        HStack(spacing: 4) {
                                            Text(dayTotal >= 0 ? "+" : "-")
                                                .font(.system(size: 10, weight: .black))
                                            NominalText(amount: abs(dayTotal), size: 12, color: .white.opacity(0.6))
                                        }
                                        .foregroundColor(dayTotal >= 0 ? Theme.income : Theme.expense.opacity(0.8))
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.top, 24)
                                .padding(.bottom, 10)
                                .textCase(nil)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        HapticManager.shared.impact(.medium)
                        await SyncManager.shared.processQueue(context: modelContext)
                        await SyncService.shared.fetchAll(context: modelContext)
                    }
                }
            }
        }
        .onAppear {
            if appeared == false {
                selectedType = initialType
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $showingEditTransaction) { transaction in
            AddTransactionView(editTransaction: transaction)
                .presentationDetents([.fraction(0.85)])
        }
    }
    
    private func getTypeIcon(_ type: String) -> String {
        switch type {
        case "Pemasukan": return "arrow.down.left"
        case "Pengeluaran": return "arrow.up.right"
        case "By Sistem": return "cpu.fill"
        default: return "list.bullet"
        }
    }
    
    private var dateRangePickerView: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("RENTANG TANGGAL")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(Theme.textSecondary)
                    .tracking(1.5)
                Text("Pilih periode riwayat")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 4) {
                DatePicker("Dari", selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                Divider().background(Color.white.opacity(0.1))
                DatePicker("Sampai", selection: $endDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            
            Button(action: { 
                filterByDate = true
                showingDateRangePicker = false 
            }) {
                Text("Terapkan")
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.accent)
                    .cornerRadius(16)
                    .shadow(color: Theme.accent.opacity(0.2), radius: 10)
            }
        }
        .padding(24)
        .background(Theme.background)
        .preferredColorScheme(.dark)
    }
    
    private func resetFilters() {
        HapticManager.shared.impact(.medium)
        withAnimation(.spring(response: 0.4)) {
            searchText = ""
            selectedType = "Semua"
            selectedCategory = "Semua"
            filterByDate = false
        }
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        HapticManager.shared.impact(.medium)
        withAnimation(.spring()) {
            TransactionService.shared.deleteTransaction(transaction, context: modelContext)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
    
    private func headerDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "HARI INI" }
        if calendar.isDateInYesterday(date) { return "KEMARIN" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMM"
        return formatter.string(from: date).uppercased()
    }
}

// MARK: - Premium History Components (Previous Logic Maintained with Re-styling)

struct HistorySummaryCard: View {
    let income: Double
    let expense: Double
    
    var body: some View {
        HStack(spacing: 0) {
            HistorySummaryItem(title: "Pemasukan", amount: income, color: Theme.income, icon: "arrow.down.left.circle.fill")
            
            Rectangle()
                .fill(Color.white.opacity(1.0))
                .frame(width: 1, height: 40)
                .opacity(0.1)
                .padding(.horizontal, 20)
            
            HistorySummaryItem(title: "Pengeluaran", amount: expense, color: Theme.expense, icon: "arrow.up.right.circle.fill")
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white.opacity(0.04))
                    .background(.ultraThinMaterial.opacity(0.1))
                    .cornerRadius(32)
                
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(colors: [.white.opacity(0.15), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
            }
        )
    }
}

struct HistorySummaryItem: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color.opacity(0.8))
                
                Text(title.uppercased())
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(Theme.textSecondary)
                    .tracking(1.5)
            }
            
            NominalText(amount: amount, size: 17, color: .white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FilterChipPremium: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                Text(title)
                    .font(.system(size: 13, weight: .bold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isSelected {
                        Theme.accent
                    } else {
                        Color.white.opacity(0.04)
                        Color.clear.background(.ultraThinMaterial.opacity(0.1))
                    }
                }
            )
            .foregroundColor(isSelected ? .black : .white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Theme.accent : Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

#endif
