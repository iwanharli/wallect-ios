import SwiftUI
import SwiftData

struct CategoryStat: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
}

struct AnalyticsView: View {
    @Environment(\.modelContext) var modelContext
    @Query var transactions: [Transaction]
    @Query var budgets: [Budget]
    @Query var allCategories: [Category]
    @State private var timeRange: String = "Bulan Ini"
    @State private var showingAddBudget: Bool = false
    
    // Time-filtered transactions
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        if timeRange == "Minggu Ini" {
            return transactions.filter { calendar.isDate($0.date, equalTo: .now, toGranularity: .weekOfYear) }
        } else {
            return transactions.filter { calendar.isDate($0.date, equalTo: .now, toGranularity: .month) }
        }
    }
    
    // Computed Data
    private var totalIncome: Double {
        filteredTransactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpense: Double {
        filteredTransactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private var categoryStats: [CategoryStat] {
        let grouped = Dictionary(grouping: filteredTransactions.filter { $0.isExpense }) { $0.category }
        let stats = grouped.map { (key, value) in
            CategoryStat(
                name: key,
                amount: value.reduce(0) { $0 + $1.amount },
                color: getColorForCategory(key)
            )
        }
        return stats.sorted { $0.amount > $1.amount }
    }
    
    private var weeklyTrend: [Double] {
        let calendar = Calendar.current
        var trends: [Double] = Array(repeating: 0, count: 7)
        for t in transactions.filter({ $0.isExpense }) {
            let daysAgo = calendar.dateComponents([.day], from: t.date, to: .now).day ?? 0
            if daysAgo >= 0 && daysAgo < 7 {
                trends[6 - daysAgo] += t.amount
            }
        }
        return trends
    }
    
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    // Header
                    HStack {
                        Text("Analisis")
                            .font(.title2.bold())
                            .foregroundColor(Theme.textMain)
                        Spacer()
                        
                        CustomSegmentedPicker(selection: $timeRange, options: ["Minggu Ini", "Bulan Ini"])
                    }
                    .padding(.horizontal)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -10)
                    
                    // Summary Cards
                    HStack(spacing: 15) {
                        SummaryCardSmall(title: "Pemasukan", amount: totalIncome, color: Theme.income)
                        SummaryCardSmall(title: "Pengeluaran", amount: totalExpense, color: Theme.expense)
                    }
                    .padding(.horizontal)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.95)
                    
                    // Category Breakdown (Donut Chart)
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Kategori Pengeluaran")
                            .font(.headline)
                            .foregroundColor(Theme.textMain)
                        
                        if categoryStats.isEmpty {
                            Text("Belum ada data pengeluaran.")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            HStack(spacing: 30) {
                                DonutChart(segments: categoryStats)
                                    .frame(width: 150, height: 150)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(categoryStats.prefix(4)) { stat in
                                        HStack(spacing: 8) {
                                            Circle().fill(stat.color).frame(width: 10, height: 10)
                                            Text(stat.name)
                                                .font(.caption)
                                                .foregroundColor(Theme.textSecondary)
                                            Spacer()
                                            Text(String(format: "%.1f%%", (stat.amount / totalExpense) * 100))
                                                .font(.caption.bold())
                                                .foregroundColor(Theme.textMain)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Theme.cardBackground.opacity(0.5))
                            .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Weekly Trends (Bar Chart)
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Tren 7 Hari Terakhir")
                            .font(.headline)
                            .foregroundColor(Theme.textMain)
                        
                        BarChart(data: weeklyTrend)
                            .frame(height: 180)
                            .padding()
                            .background(Theme.cardBackground.opacity(0.5))
                            .cornerRadius(25)
                    }
                    .padding(.horizontal)
                    
                    // Budgets Section
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Target Anggaran")
                                .font(.headline)
                                .foregroundColor(Theme.textMain)
                            Spacer()
                            Button(action: { showingAddBudget = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Theme.accent)
                                    .font(.title3)
                            }
                        }
                        
                        if budgets.isEmpty {
                            Text("Belum ada anggaran. Tap + untuk membuat.")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            VStack(spacing: 15) {
                                ForEach(budgets) { budget in
                                    let spending = transactions.filter { 
                                        $0.category == budget.category && 
                                        $0.isExpense && 
                                        Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .month)
                                    }.reduce(0) { $0 + $1.amount }
                                    
                                    BudgetRow(budget: budget, currentSpending: spending)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Top Categories List
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Daftar Pengeluaran Terbesar")
                            .font(.headline)
                            .foregroundColor(Theme.textMain)
                        
                        ForEach(categoryStats) { stat in
                            HStack {
                                Circle()
                                    .fill(stat.color.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: getIconForCategory(stat.name))
                                            .font(.system(size: 14))
                                            .foregroundColor(stat.color)
                                    )
                                
                                Text(stat.name)
                                    .font(.subheadline.bold())
                                    .foregroundColor(Theme.textMain)
                                
                                Spacer()
                                
                                Text(CurrencyFormatter.format(stat.amount))
                                    .font(.subheadline.bold())
                                    .foregroundColor(Theme.textMain)
                            }
                            .padding()
                            .background(Theme.cardBackground.opacity(0.3))
                            .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal)
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 120)
                }
                .padding(.top, 20)
            }
        }
        .sheet(isPresented: $showingAddBudget) {
            AddBudgetView()
                .presentationDetents([.fraction(0.85)])
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
    
    private func getColorForCategory(_ name: String) -> Color {
        // We can still have some "theme" colors for top categories
        // or just return a default based on the model if we add color to it later.
        switch name {
        case "Food": return Color.orange
        case "Shopping": return Color.pink
        case "Transport": return Color.blue
        case "Entertainment": return Color.purple
        case "Work": return Theme.income
        default: return Theme.accent
        }
    }
    
    private func getIconForCategory(_ name: String) -> String {
        if let category = allCategories.first(where: { $0.name == name }) {
            return category.icon
        }
        return "dollarsign.circle"
    }
}

struct CustomSegmentedPicker: View {
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                let isSelected = selection == option
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = option
                    }
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }) {
                    Text(option)
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            ZStack {
                                if isSelected {
                                    Capsule()
                                        .fill(Theme.accent)
                                        .matchedGeometryEffect(id: "activeTab", in: namespace)
                                }
                            }
                        )
                        .foregroundColor(isSelected ? .black : Theme.textSecondary)
                }
            }
        }
        .padding(4)
        .background(Theme.cardBackground.opacity(0.5))
        .clipShape(Capsule())
    }
    
    @Namespace private var namespace
}

struct SummaryCardSmall: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            Text(CurrencyFormatter.format(amount))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct DonutChart: View {
    let segments: [CategoryStat]
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<segments.count, id: \.self) { index in
                Circle()
                    .trim(from: startProgress(for: index) * animationProgress, to: endProgress(for: index) * animationProgress)
                    .stroke(segments[index].color, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            
            VStack {
                Text("Total")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                Text(CurrencyFormatter.format(segments.reduce(0) { $0 + $1.amount }))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textMain)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animationProgress = 1
            }
        }
        .onChange(of: segments.count) {
            animationProgress = 0
            withAnimation(.easeOut(duration: 1.0)) {
                animationProgress = 1
            }
        }
    }
    
    private func startProgress(for index: Int) -> CGFloat {
        let total = segments.reduce(0) { $0 + $1.amount }
        guard total > 0 else { return 0 }
        let sum = segments.prefix(index).reduce(0) { $0 + $1.amount }
        return CGFloat(sum / total)
    }
    
    private func endProgress(for index: Int) -> CGFloat {
        let total = segments.reduce(0) { $0 + $1.amount }
        guard total > 0 else { return 0 }
        let sum = segments.prefix(index + 1).reduce(0) { $0 + $1.amount }
        return CGFloat(sum / total)
    }
}

struct BarChart: View {
    let data: [Double]
    @State private var animateChart = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            let max = (data.max() ?? 1) == 0 ? 1 : (data.max() ?? 1)
            
            ForEach(0..<data.count, id: \.self) { index in
                VStack(spacing: 8) {
                    Group {
                        if data[index] > 0 {
                            Capsule()
                                .fill(Theme.mainGradient)
                                .frame(height: animateChart ? CGFloat(data[index] / max) * 120 : 0)
                        } else {
                            Capsule()
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 10)
                        }
                    }
                    
                    Text(getDayName(index))
                        .font(.system(size: 10))
                        .foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                animateChart = true
            }
        }
    }
    
    private func getDayName(_ index: Int) -> String {
        let days = ["S", "S", "R", "K", "J", "S", "M"]
        return days[index]
    }
}

// MARK: - Budget Components
struct BudgetRow: View {
    @Environment(\.modelContext) var modelContext
    let budget: Budget
    let currentSpending: Double
    
    private var progress: Double {
        guard budget.limit > 0 else { return 0 }
        return min(currentSpending / budget.limit, 1.0)
    }
    
    private var statusColor: Color {
        if progress < 0.7 { return Theme.income }
        if progress < 0.9 { return Color.orange }
        return Theme.expense
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(budget.category)
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.textMain)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption.bold())
                    .foregroundColor(statusColor)
            }
            
            // Modern Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.05))
                    Capsule()
                        .fill(statusColor)
                        .frame(width: geo.size.width * CGFloat(progress))
                        .shadow(color: statusColor.opacity(0.3), radius: 5, x: 0, y: 0)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text(CurrencyFormatter.format(currentSpending))
                    .font(.caption.bold())
                    .foregroundColor(Theme.textMain)
                Text("/")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                Text(CurrencyFormatter.format(budget.limit))
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                
                Spacer()
                
                if progress >= 1.0 {
                    Text("Over Budget!")
                        .font(.caption.bold())
                        .foregroundColor(Theme.expense)
                } else if progress >= 0.8 {
                    Text("Hampir Habis")
                        .font(.caption.bold())
                        .foregroundColor(Color.orange)
                }
            }
        }
        .padding()
        .background(Theme.cardBackground.opacity(0.4))
        .cornerRadius(20)
        .contextMenu {
            Button(role: .destructive) {
                let budgetId = budget.id
                modelContext.delete(budget)
                SyncManager.shared.enqueue(endpoint: "budgets/\(budgetId)", method: .delete, context: modelContext)
            } label: {
                Label("Hapus Anggaran", systemImage: "trash")
            }
        }
    }
}

struct AddBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Query var allCategories: [Category]
    
    @State private var amount: String = "0"
    @State private var selectedCategory: String = "Food"
    
    private var expenseCategories: [String] {
        allCategories.filter { $0.isExpense }.map { $0.name }
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                Text("Set Anggaran")
                    .font(.title3.bold())
                    .foregroundColor(Theme.textMain)
                    .padding(.top)
                
                // Amount
                VStack(spacing: 8) {
                    Text("Batas Bulanan")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                    Text(CurrencyFormatter.formatRawString(amount))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.accent)
                }
                
                // Category List
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(expenseCategories, id: \.self) { cat in
                            Button(action: {
                                selectedCategory = cat
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }) {
                                Text(cat)
                                    .font(.subheadline.bold())
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(selectedCategory == cat ? Theme.accent : Theme.cardBackground)
                                    .foregroundColor(selectedCategory == cat ? .black : Theme.textSecondary)
                                    .cornerRadius(15)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Keypad
                CustomBudgetEntryKeypad(amount: $amount)
                
                // Save Button
                Button(action: saveBudget) {
                    Text("Simpan Anggaran")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accent)
                        .cornerRadius(20)
                }
                .padding(.horizontal)
                .disabled(amount == "0")
                .opacity(amount == "0" ? 0.5 : 1)
                
                Spacer()
            }
        }
    }
    
    private func saveBudget() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        let limit = CurrencyFormatter.toDouble(amount)
        let newBudget = Budget(category: selectedCategory, limit: limit)
        modelContext.insert(newBudget)
        SyncManager.shared.enqueue(endpoint: "budgets", method: .post, body: newBudget.toDTO(), context: modelContext)
        dismiss()
    }
}

struct CustomBudgetEntryKeypad: View {
    @Binding var amount: String
    let buttons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["000", "0", "delete.left"]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 15) {
                    ForEach(row, id: \.self) { button in
                        Button(action: { handleInput(button) }) {
                            Group {
                                if button == "delete.left" {
                                    Image(systemName: button)
                                } else {
                                    Text(button)
                                        .font(.title3.bold())
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func handleInput(_ symbol: String) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if symbol == "delete.left" {
            if amount.count > 1 { amount.removeLast() } else { amount = "0" }
        } else if symbol == "000" {
            if amount != "0" { amount += "000" }
        } else {
            if amount == "0" { amount = symbol } else if amount.count < 12 { amount += symbol }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Transaction.self, configurations: config)
    
    let sampleData = [
        Transaction(title: "Lunch", amount: 120000, category: "Food", isExpense: true),
        Transaction(title: "Grab", amount: 50000, category: "Transport", isExpense: true),
        Transaction(title: "Spotify", amount: 55000, category: "Entertainment", isExpense: true),
        Transaction(title: "Salad", amount: 45000, category: "Food", isExpense: true),
        Transaction(title: "Bonus", amount: 2000000, category: "Work", isExpense: false)
    ]
    
    for t in sampleData {
        container.mainContext.insert(t)
    }
    
    return AnalyticsView()
        .modelContainer(container)
}
