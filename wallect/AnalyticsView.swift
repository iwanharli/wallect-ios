import SwiftUI
import SwiftData

struct AnalyticsView: View {
    static var didInitialLoad = false
    @Environment(\.modelContext) var modelContext
    @Query var transactions: [Transaction]
    @Query var allCategories: [Category]
    @State private var timeRange: String = "30 Hari"
    @State private var appeared = false
    @State private var isLoading = true
    @State private var isExpenseMode = true
    
    // Time-filtered transactions (Current Period)
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let days = (timeRange == "7 Hari") ? 7 : 30
        let cutoff = calendar.date(byAdding: .day, value: -days, to: .now) ?? .now
        return transactions.filter { $0.date >= cutoff && !$0.isSystem }
    }
    
    // Time-filtered transactions (Previous Period for MoM)
    private var previousFilteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let days = (timeRange == "7 Hari") ? 7 : 30
        let currentCutoff = calendar.date(byAdding: .day, value: -days, to: .now) ?? .now
        let previousCutoff = calendar.date(byAdding: .day, value: -days, to: currentCutoff) ?? .now
        return transactions.filter { $0.date >= previousCutoff && $0.date < currentCutoff && !$0.isSystem }
    }
    
    // Computed Data
    private var totalIncome: Double {
        filteredTransactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpense: Double {
        filteredTransactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private var previousIncome: Double {
        previousFilteredTransactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private var previousExpense: Double {
        previousFilteredTransactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalSavings: Double {
        let calendar = Calendar.current
        let days = (timeRange == "7 Hari") ? 7 : 30
        let cutoff = calendar.date(byAdding: .day, value: -days, to: .now) ?? .now
        
        // Savings = Allocations into Goal wallets (Income transactions to goals)
        return transactions.filter { tx in
            tx.date >= cutoff && 
            tx.title.lowercased().contains("alokasi") && 
            !tx.isExpense &&
            tx.wallet?.isGoal == true
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var savingsRate: Double {
        guard totalIncome > 0 else { return 0 }
        return (totalSavings / totalIncome) * 100
    }
    
    private var categoryStats: [CategoryStat] {
        let relevantTransactions = filteredTransactions.filter { $0.isExpense == isExpenseMode }
        let grouped = Dictionary(grouping: relevantTransactions) { $0.category }
        let stats = grouped.map { (key, value) in
            CategoryStat(
                name: key,
                amount: value.reduce(0) { $0 + $1.amount },
                color: getCategoryColor(key)
            )
        }
        return stats.sorted { $0.amount > $1.amount }
    }
    
    private var weeklyTrend: [Double] {
        let calendar = Calendar.current
        var trends: [Double] = Array(repeating: 0, count: 7)
        for t in transactions.filter({ $0.isExpense == isExpenseMode && !$0.isSystem }) {
            let daysAgo = calendar.dateComponents([.day], from: t.date, to: .now).day ?? 0
            if daysAgo >= 0 && daysAgo < 7 {
                trends[6 - daysAgo] += t.amount
            }
        }
        return trends
    }
    
    private var monthlyTrends: [MonthlyStat] {
        let calendar = Calendar.current
        let relevantTransactions = transactions.filter { $0.isExpense == isExpenseMode && !$0.isSystem }
        
        // Generate last 6 months
        var stats: [MonthlyStat] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        for i in (0..<6).reversed() {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: .now) else { continue }
            let month = calendar.component(.month, from: monthDate)
            let year = calendar.component(.year, from: monthDate)
            
            let total = relevantTransactions.filter { tx in
                let txMonth = calendar.component(.month, from: tx.date)
                let txYear = calendar.component(.year, from: tx.date)
                return txMonth == month && txYear == year
            }.reduce(0) { $0 + $1.amount }
            
            stats.append(MonthlyStat(name: dateFormatter.string(from: monthDate).uppercased(), amount: total))
        }
        return stats
    }
    
    var body: some View {
        ZStack {
            Theme.DynamicBackground()
            
            ScrollView(showsIndicators: false) {
                if isLoading {
                    AnalyticsSkeletonView()
                        .transition(.opacity)
                } else {
                    VStack(spacing: 32) {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ANALISIS KEUANGAN")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(Theme.accent.opacity(0.8))
                                        .tracking(2.0)
                                    Text("Ringkasan")
                                        .font(.system(size: 32, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                
                                CustomSegmentedPicker(selection: $timeRange, options: ["7 Hari", "30 Hari"])
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Summary Cards
                        HStack(spacing: 16) {
                            SummaryCardPremium(
                                title: "PEMASUKAN",
                                amount: totalIncome,
                                previousAmount: previousIncome,
                                color: Theme.income,
                                icon: "arrow.down.right.circle.fill",
                                isIncome: true,
                                isSelected: !isExpenseMode,
                                action: { withAnimation(.spring) { isExpenseMode = false } }
                            )
                            SummaryCardPremium(
                                title: "PENGELUARAN",
                                amount: totalExpense,
                                previousAmount: previousExpense,
                                color: Theme.expense,
                                icon: "arrow.up.right.circle.fill",
                                isIncome: false,
                                isSelected: isExpenseMode,
                                action: { withAnimation(.spring) { isExpenseMode = true } }
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // Insights Section
                        FinancialInsightsCard(income: totalIncome, expense: totalExpense, savingsRate: savingsRate)
                            .padding(.horizontal, 24)
                        
                        // Category Breakdown
                        VStack(alignment: .leading, spacing: 20) {
                            Text("PROPORSI KATEGORI \(isExpenseMode ? "PENGELUARAN" : "PEMASUKAN")")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(Theme.textSecondary)
                                .tracking(1.5)
                                .padding(.horizontal, 24)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 32)
                                    .fill(Color.white.opacity(0.04))
                                    .background(.ultraThinMaterial.opacity(0.1))
                                    .cornerRadius(32)
                                    .overlay(RoundedRectangle(cornerRadius: 32).stroke(Theme.glassBorder, lineWidth: 1))
                                
                                if categoryStats.isEmpty {
                                    emptyState
                                } else {
                                    categoryDistributionContent
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Top Spending List
                        if !categoryStats.isEmpty {
                            topSpendingSection
                        }
                        
                        // Weekly Trends Card
                        weeklyTrendSection
                        
                        // Monthly Trends Section
                        monthlyTrendSection
                        
                        Spacer(minLength: 120)
                    }
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
            
            if AnalyticsView.didInitialLoad {
                isLoading = false
            } else if isLoading {
                Task {
                    // Very fast shimmer for first load
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    AnalyticsView.didInitialLoad = true
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            isLoading = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Extracted Components for Performance
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 40))
                .foregroundColor(Theme.textSecondary.opacity(0.3))
            Text("Belum ada data transaksi.")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(60)
        .frame(maxWidth: .infinity)
    }
    
    private var categoryDistributionContent: some View {
        VStack(spacing: 25) {
            HStack(spacing: 30) {
                DonutChartPremium(segments: categoryStats)
                    .frame(width: 150, height: 150)
                
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(categoryStats.prefix(4)) { stat in
                        HStack(spacing: 10) {
                            Circle().fill(stat.color).frame(width: 8, height: 8)
                                .shadow(color: stat.color.opacity(0.5), radius: 4)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(stat.name)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                 let percentage = (isExpenseMode ? totalExpense : totalIncome) > 0 ? (stat.amount / (isExpenseMode ? totalExpense : totalIncome)) * 100 : 0
                                Text(String(format: "%.1f%%", percentage))
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(24)
    }
    
    private var topSpendingSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(isExpenseMode ? "PENGELUARAN" : "PEMASUKAN") TERBESAR")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(Theme.textSecondary)
                .tracking(1.5)
                .padding(.horizontal, 24)
            
            VStack(spacing: 1) {
                ForEach(categoryStats.prefix(5)) { stat in
                    TopSpendingRow(stat: stat, total: isExpenseMode ? totalExpense : totalIncome)
                }
            }
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.04))
            .background(.ultraThinMaterial.opacity(0.1))
            .cornerRadius(32)
            .overlay(RoundedRectangle(cornerRadius: 32).stroke(Theme.glassBorder, lineWidth: 1))
            .padding(.horizontal, 24)
        }
    }
    
    private var weeklyTrendSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("TREN \(isExpenseMode ? "PENGELUARAN" : "PEMASUKAN") 7 HARI")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(Theme.textSecondary)
                .tracking(1.5)
                .padding(.horizontal, 24)
            
            VStack(spacing: 20) {
                BarChartPremium(data: weeklyTrend, color: isExpenseMode ? Theme.expense : Theme.income)
                    .frame(height: 180)
            }
            .padding(24)
            .background(Color.white.opacity(0.04))
            .background(.ultraThinMaterial.opacity(0.1))
            .cornerRadius(32)
            .overlay(RoundedRectangle(cornerRadius: 32).stroke(Theme.glassBorder, lineWidth: 1))
            .padding(.horizontal, 24)
        }
    }
    
    private var monthlyTrendSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("TREN \(isExpenseMode ? "PENGELUARAN" : "PEMASUKAN") 6 BULAN")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(Theme.textSecondary)
                .tracking(1.5)
                .padding(.horizontal, 24)
            
            VStack(spacing: 20) {
                MonthlyBarChartPremium(stats: monthlyTrends, color: isExpenseMode ? Theme.expense : Theme.income)
                    .frame(height: 180)
            }
            .padding(24)
            .background(Color.white.opacity(0.04))
            .background(.ultraThinMaterial.opacity(0.1))
            .cornerRadius(32)
            .overlay(RoundedRectangle(cornerRadius: 32).stroke(Theme.glassBorder, lineWidth: 1))
            .padding(.horizontal, 24)
        }
    }
    
    private func getCategoryColor(_ categoryName: String) -> Color {
        if let category = allCategories.first(where: { $0.name == categoryName }) {
            return Color(hex: category.hexColor)
        }
        return Theme.accent
    }
}
