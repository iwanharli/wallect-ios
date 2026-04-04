import SwiftUI
import SwiftData

struct AllTransactionsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]
    @Query var allCategories: [Category]
    
    // Filtering States
    @State private var searchText: String = ""
    @State private var selectedType: String = "Semua"
    @State private var selectedCategory: String = "Semua"
    @State private var selectedDate: Date = .now
    @State private var filterByDate: Bool = false
    @State private var showingEditTransaction: Transaction? = nil
    
    @State private var appeared = false
    
    private let types = ["Semua", "Pemasukan", "Pengeluaran"]
    
    private var categories: [String] {
        let names = allCategories.map { $0.name }
        return ["Semua"] + Array(Set(names)).sorted()
    }
    
    // Grouping by Date for Sectioned View
    private var groupedTransactions: [(Date, [Transaction])] {
        let filtered = transactions.filter { transaction in
            let matchesSearch = searchText.isEmpty || 
                                transaction.title.localizedCaseInsensitiveContains(searchText) || 
                                transaction.note.localizedCaseInsensitiveContains(searchText)
            
            let matchesType = selectedType == "Semua" || 
                              (selectedType == "Pemasukan" && !transaction.isExpense) || 
                              (selectedType == "Pengeluaran" && transaction.isExpense)
            
            let matchesCategory = selectedCategory == "Semua" || transaction.category == selectedCategory
            
            let matchesDate = !filterByDate || Calendar.current.isDate(transaction.date, inSameDayAs: selectedDate)
            
            return matchesSearch && matchesType && matchesCategory && matchesDate
        }
        
        let grouped = Dictionary(grouping: filtered) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            // Background ambient glow (Deep subtle)
            Circle()
                .fill(Theme.accent.opacity(0.08))
                .blur(radius: 100)
                .frame(width: 400, height: 400)
                .offset(y: -400)
            
            VStack(spacing: 0) {
                // Header (Glass)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundColor(Theme.textMain)
                            .frame(width: 44, height: 44)
                            .background(Theme.cardBackground.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Text("Transaksi")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Theme.textMain)
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    // Count indicator
                    Text("\(transactions.count) Total")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Theme.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.cardBackground.opacity(0.5))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // Content
                VStack(spacing: 0) {
                    // Filter & Search Group (Minimalist)
                    VStack(spacing: 15) {
                        // Minimalist Search
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Theme.textSecondary)
                            TextField("Cari transaksi...", text: $searchText)
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 48)
                        .background(Theme.cardBackground.opacity(0.4))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Compact Filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                // Date Filter Chip
                                HStack(spacing: 6) {
                                    ZStack {
                                        FilterChip(title: filterByDate ? formatDate(selectedDate) : "Pilih Tanggal", isSelected: filterByDate) {
                                            // The activation is now handled by onChange, but we'll keep this for haptics
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                        
                                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                            .labelsHidden()
                                            .opacity(0.015)
                                            .colorScheme(.dark)
                                    }
                                    
                                    if filterByDate {
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                filterByDate = false
                                            }
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(Theme.textSecondary.opacity(0.8))
                                                .font(.system(size: 18))
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                
                                // Divider
                                Color.white.opacity(0.1).frame(width: 1, height: 20)
                                
                                // Type Filters
                                ForEach(types, id: \.self) { type in
                                    FilterChip(title: type, isSelected: selectedType == type) {
                                        selectedType = type
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                }
                                
                                // Category Filters
                                ForEach(categories, id: \.self) { category in
                                    if category != "Semua" {
                                        FilterChip(title: category, isSelected: selectedCategory == category) {
                                            selectedCategory = category
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                    .background(Color.black.opacity(0.2))
                    .clipShape(RoundedCorner(radius: 30, corners: [.bottomLeft, .bottomRight]))
                    
                    // List
                    if groupedTransactions.isEmpty {
                        EmptyStateView(action: {}) // Reuse from HomeView if available or create minimalist one
                            .padding(.top, 100)
                    } else {
                        List {
                            ForEach(groupedTransactions, id: \.0) { date, items in
                                Section {
                                    ForEach(items) { transaction in
                                        TransactionRow(transaction: transaction)
                                            .listRowBackground(Color.clear)
                                            .listRowSeparator(.hidden)
                                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                            .onTapGesture {
                                                showingEditTransaction = transaction
                                            }
                                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                Button(role: .destructive) {
                                                    deleteTransaction(transaction)
                                                } label: {
                                                    Label("Hapus", systemImage: "trash.fill")
                                                }
                                            }
                                    }
                                } header: {
                                    Text(headerDate(date))
                                        .font(.system(size: 13, weight: .black))
                                        .foregroundColor(Theme.textSecondary)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 4)
                                        .textCase(.uppercase)
                                        .tracking(1.5)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $showingEditTransaction) { transaction in
            AddTransactionView(editTransaction: transaction)
                .presentationDetents([.fraction(0.85)])
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
        .onChange(of: selectedDate) { _ in
            if !filterByDate {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    filterByDate = true
                }
            }
        }
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            TransactionService.shared.deleteTransaction(transaction, context: modelContext)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
    
    private func headerDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Hari Ini"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Kemarin"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, dd MMM"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    AllTransactionsView()
}
