#if !WIDGET_EXTENSION
import SwiftUI
import SwiftData

struct BudgetDetailView: View {
    @Binding var isPresented: Bool
    @Environment(\.modelContext) var modelContext
    let budget: Budget
    
    @Query(sort: \Transaction.date, order: .reverse) var allTransactions: [Transaction]
    @State private var showingEditBudget = false
    @State private var showingDeleteAlert = false
    
    private var filteredTransactions: [Transaction] {
        var budgetStartDate = Calendar.current.startOfDay(for: budget.startDate ?? .distantPast)
        var budgetEndDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: budget.endDate ?? .distantFuture) ?? .distantFuture
        
        // If recurring, overwrite with CURRENT month boundaries
        if budget.isRecurring {
            let calendar = Calendar.current
            let now = Date()
            if let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) {
                budgetStartDate = startOfMonth
                if let range = calendar.range(of: .day, in: .month, for: now),
                   let endOfMonth = calendar.date(byAdding: .day, value: range.count - 1, to: startOfMonth) {
                    budgetEndDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfMonth) ?? endOfMonth
                }
            }
        }
        
        let filtered = allTransactions.filter { 
            let catMatch = $0.category.lowercased().trimmingCharacters(in: .whitespaces) == budget.category.lowercased().trimmingCharacters(in: .whitespaces)
            let dateMatch = $0.date >= budgetStartDate && $0.date <= budgetEndDate
            let typeMatch = $0.isExpense
            
            return catMatch && dateMatch && typeMatch
        }
        
        return filtered
    }
    
    private var totalSpent: Double {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }
    
    private var progress: Double {
        guard budget.limit > 0 else { return 0 }
        return min(totalSpent / budget.limit, 1.0)
    }
    
    private var remainingAmount: Double {
        max(budget.limit - totalSpent, 0)
    }
    
    private var remainingPercent: Int {
        max(0, 100 - Int(progress * 100))
    }
    
    private var statusColor: Color {
        if progress < 0.7 { return Theme.income }
        if progress < 0.9 { return Color.orange }
        return Theme.expense
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Progress Section
                        progressCard
                        
                        // Transactions Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("TRANSAKSI TERKAIT")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(Theme.textSecondary)
                                    .tracking(1.5)
                                Spacer()
                                Text("\(filteredTransactions.count) Item")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Theme.textSecondary)
                            }
                            .padding(.horizontal)
                            
                            if filteredTransactions.isEmpty {
                                emptyState
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredTransactions) { transaction in
                                        TransactionRow(transaction: transaction)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top)
                }
            }
        }
        .sheet(isPresented: $showingEditBudget) {
            AddBudgetView(editBudget: budget)
                .presentationDetents([.fraction(0.85)])
        }
        .alert("Hapus Anggaran?", isPresented: $showingDeleteAlert) {
            Button("Batal", role: .cancel) { }
            Button("Hapus", role: .destructive) {
                deleteBudget()
            }
        } message: {
            Text("Apakah Kamu yakin ingin menghapus anggaran kategori \(budget.category)? Tindakan ini tidak dapat dibatalkan.")
        }
    }
    
    private func deleteBudget() {
        HapticManager.shared.impact(.heavy)
        modelContext.delete(budget)
        SyncManager.shared.enqueue(endpoint: "budgets/\(budget.id)", method: .delete, body: nil, context: modelContext)
        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
            isPresented = false
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                    isPresented = false
                }
            }) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
            
            Text(budget.category)
                .font(.headline)
                .foregroundColor(Theme.textMain)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: { 
                    HapticManager.shared.impact(.medium)
                    showingEditBudget = true 
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(Theme.accent)
                }
                
                Button(action: { 
                    HapticManager.shared.impact(.medium)
                    showingDeleteAlert = true 
                }) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                        .foregroundColor(Theme.expense)
                }
            }
        }
        .padding()
        .background(Theme.background.opacity(0.8))
    }
    
    private var progressCard: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.05), lineWidth: 15)
                    .frame(width: 140, height: 140)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        AngularGradient(
                            colors: [statusColor.opacity(0.6), statusColor],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(progress * 360 - 90)
                        ),
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: statusColor.opacity(0.4), radius: 10)
                
                VStack(spacing: 2) {
                    Text("\(remainingPercent)%")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(Theme.textMain)
                    Text("SISA")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Theme.textSecondary)
                }
            }
            
            HStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TERPAKAI")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Theme.textSecondary)
                    Text(CurrencyFormatter.format(totalSpent))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.expense)
                }
                
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 30)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("TOTAL LIMIT")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Theme.textSecondary)
                    Text(CurrencyFormatter.format(budget.limit))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.accent)
                }
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Theme.cardBackground.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle")
                .font(.largeTitle)
                .foregroundColor(Theme.textSecondary)
            Text("Belum ada transaksi di rentang waktu ini")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#endif
