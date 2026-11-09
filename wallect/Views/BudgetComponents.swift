#if !WIDGET_EXTENSION
import SwiftUI
import SwiftData

// MARK: - Budget Components

struct BudgetRow: View {
    @Environment(\.modelContext) var modelContext
    @Query var allCategories: [Category]
    let budget: Budget
    let transactions: [Transaction]
    var onTap: (() -> Void)? = nil
    
    private var currentSpending: Double {
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
        
        let filtered = transactions.filter { 
            let catMatch = $0.category.lowercased().trimmingCharacters(in: .whitespaces) == budget.category.lowercased().trimmingCharacters(in: .whitespaces)
            let dateMatch = $0.date >= budgetStartDate && $0.date <= budgetEndDate
            let typeMatch = $0.isExpense
            
            return catMatch && dateMatch && typeMatch
        }
        
        return filtered.reduce(0) { $0 + $1.amount }
    }
    
    private var progress: Double {
        guard budget.limit > 0 else { return 0 }
        return min(currentSpending / budget.limit, 1.0)
    }
    
    private var statusColor: Color {
        if progress < 0.7 { return Theme.income }
        if progress < 0.9 { return Color.orange }
        return Theme.expense
    }
    
    private var categoryIcon: String {
        allCategories.first { $0.name == budget.category }?.icon ?? "dollarsign.circle"
    }
    
    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 16) {
                // Category Icon with Status Ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 3)
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(statusColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: statusColor.opacity(0.4), radius: 3)
                    
                    Image(systemName: categoryIcon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(statusColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.category)
                        .font(.headline)
                        .foregroundColor(Theme.textMain)
                    
                    Text("\(formatDate(budget.startDate ?? Date.now)) - \(formatDate(budget.endDate ?? Date.now))")
                        .font(.caption2)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    let remainingPercent = max(0, 100 - Int(progress * 100))
                    
                    NominalText(
                        amount: max(budget.limit - currentSpending, 0),
                        size: 15,
                        color: progress >= 1.0 ? Theme.expense : Theme.textMain
                    )
                    
                    Text(progress >= 1.0 ? "Over Budget" : "\(remainingPercent)% Sisa")
                        .font(.system(size: 10).bold())
                        .foregroundColor(progress >= 1.0 ? Theme.expense : Theme.textSecondary)
                        .textCase(.uppercase)
                }
            }
            .padding(16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Theme.cardBackground.opacity(0.6))
                    
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(LinearGradient(colors: [.white.opacity(0.12), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                }
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                let budgetId = budget.id
                modelContext.delete(budget)
                SyncManager.shared.enqueue(endpoint: "budgets/\(budgetId)", method: .delete, context: modelContext)
            } label: {
                Label("Hapus Anggaran", systemImage: "trash")
            }
            
            Button {
                onTap?()
            } label: {
                Label("Lihat Detail & Transaksi", systemImage: "list.bullet.indent")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}

struct AddBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Query var allCategories: [Category]
    
    // Edit Support
    var editBudget: Budget? = nil
    
    @State private var amount: String = "0"
    @State private var selectedCategory: String = "Food"
    @State private var isRecurring: Bool = false
    @State private var showingCategoryManager = false
    @State private var startDate: Date = .now
    @State private var endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
    
    private var currentColor: Color {
        if let cat = allCategories.first(where: { $0.name == selectedCategory }) {
            return Color(hex: cat.hexColor)
        }
        return colorForCategory(selectedCategory)
    }
    
    private var expenseCategories: [String] {
        allCategories.filter { $0.isExpense }.map { $0.name }
    }
    
    var body: some View {
        ZStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                // Dynamic Glow Blobs
                Circle()
                    .fill(currentColor.opacity(0.15))
                    .frame(width: 400, height: 400)
                    .blur(radius: 80)
                    .offset(x: -150, y: -200)
                
                Circle()
                    .fill(currentColor.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: 100, y: 150)
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: selectedCategory)
            
            VStack(spacing: 0) {
                // Header (Minimalist)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.title3)
                            .foregroundColor(Theme.textSecondary)
                    }
                    Spacer()
                    Text(editBudget == nil ? "Set Anggaran" : "Edit Anggaran")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.textMain)
                    Spacer()
                    Button(action: saveBudget) {
                        Text("Simpan")
                            .font(.system(size: 13, weight: .black))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(amount == "0" ? Color.clear : currentColor.opacity(0.1))
                            .foregroundColor(amount == "0" ? Theme.textSecondary : currentColor)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(amount == "0" ? Color.clear : currentColor.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .disabled(amount == "0")
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                .padding(.bottom, 15)
                
                // Section 1: Amount Display & Category Picker (Full Width & Fixed)
                VStack(spacing: 25) {
                    VStack(spacing: 8) {
                        Text("Batas Pengeluran")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(Theme.textSecondary)
                            .tracking(1.5)
                            .textCase(.uppercase)
                        
                        Text(CurrencyFormatter.formatRawString(amount))
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [currentColor, currentColor.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: currentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.top, 5)
                    
                    // Category Picker (Inside Card)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(expenseCategories, id: \.self) { cat in
                                Button(action: {
                                    selectedCategory = cat
                                    HapticManager.shared.impact(.light)
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: getIconForCategory(cat))
                                            .font(.system(size: 10))
                                        Text(cat)
                                            .font(.system(size: 11, weight: .bold))
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == cat ? currentColor : Color.white.opacity(0.06))
                                    .foregroundColor(selectedCategory == cat ? (currentColor.isLight ? .black : .white) : Theme.textMain)
                                    .cornerRadius(10)
                                    .shadow(color: selectedCategory == cat ? currentColor.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
                                }
                            }
                            
                            // Manage Button (Moved to Right)
                            Button(action: { showingCategoryManager = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 10))
                                    Text("Kelola")
                                        .font(.system(size: 11, weight: .bold))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(Theme.accent)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                    .padding(.bottom, 25)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 25)
                .background(
                    Theme.cardBackground.opacity(0.2)
                        .background(.ultraThinMaterial)
                )
                .cornerRadius(0) // Full width fixed header
                .padding(.bottom, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Section 2: Date Range (Premium Vertical Connector Style)
                        VStack(spacing: 0) {
                            HStack {
                                Text("MASA BERLAKU")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(Theme.textSecondary)
                                    .tracking(1)
                                Spacer()
                                Button(action: setThisMonth) {
                                    Text("Bulan Ini")
                                        .font(.system(size: 10, weight: .black))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(currentColor.opacity(0.1))
                                        .foregroundColor(currentColor)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                            
                            VStack(spacing: 0) {
                                // Start Date
                                HStack(spacing: 15) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 8))
                                        .foregroundColor(currentColor)
                                        .background(
                                            VStack {
                                                Spacer()
                                                Rectangle()
                                                    .fill(currentColor.opacity(0.3))
                                                    .frame(width: 1, height: 25)
                                            }
                                        )
                                    
                                    Text("Mulai")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Theme.textSecondary)
                                    
                                    Spacer()
                                    
                                    DatePicker("", selection: $startDate, displayedComponents: .date)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                }
                                .padding(.horizontal, 20)
                                .frame(height: 50)
                                
                                // End Date
                                HStack(spacing: 15) {
                                    Image(systemName: "square.fill")
                                        .font(.system(size: 8))
                                        .foregroundColor(currentColor)
                                        .background(
                                            VStack {
                                                Rectangle()
                                                    .fill(currentColor.opacity(0.3))
                                                    .frame(width: 1, height: 25)
                                                Spacer()
                                            }
                                        )
                                    
                                    Text("Hingga")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Theme.textSecondary)
                                    
                                    Spacer()
                                    
                                    DatePicker("", selection: $endDate, displayedComponents: .date)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                }
                                .padding(.horizontal, 20)
                                .frame(height: 50)
                            }
                            .padding(.bottom, 10)
                        }
                        .background(Theme.cardBackground.opacity(0.3))
                        .cornerRadius(20)
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                        
                        // Section 4: Recurring Option
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Anggaran Tetap")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Ulangi otomatis setiap bulan")
                                    .font(.system(size: 11))
                                    .foregroundColor(Theme.textSecondary)
                            }
                            Spacer()
                            Toggle("", isOn: $isRecurring)
                                .toggleStyle(SwitchToggleStyle(tint: currentColor))
                                .labelsHidden()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                        .background(Theme.cardBackground.opacity(0.3))
                        .cornerRadius(18)
                        .padding(.horizontal, 25)
                        
                        // Section 5: Keypad (Now Inside ScrollView)
                        CustomBudgetEntryKeypad(amount: $amount)
                            .padding(.top, 10)
                            .padding(.bottom, 30)
                    }
                    .padding(.top, 10)
                }
            }
        }
        .sheet(isPresented: $showingCategoryManager) {
            CategoryManagerView()
        }
        .onAppear {
            if let edit = editBudget {
                amount = String(Int(edit.limit))
                selectedCategory = edit.category
                isRecurring = edit.isRecurring
                startDate = edit.startDate ?? .now
                endDate = edit.endDate ?? (Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now)
            }
        }
    }
    
    private func setThisMonth() {
        let calendar = Calendar.current
        let now = Date()
        if let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) {
            startDate = startOfMonth
            if let range = calendar.range(of: .day, in: .month, for: now),
               let endOfMonth = calendar.date(byAdding: .day, value: range.count - 1, to: startOfMonth) {
                endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfMonth) ?? endOfMonth
            }
        }
        HapticManager.shared.impact(.medium)
    }
    
    private func colorForCategory(_ name: String) -> Color {
        if let cat = allCategories.first(where: { $0.name == name }) {
            return Color(hex: cat.hexColor)
        }
        
        switch name.lowercased() {
        case "food", "makan": return Color(hex: "FF9F1C")
        case "shopping", "belanja": return Color(hex: "FF006E")
        case "transport", "transportasi": return Color(hex: "3A86FF")
        case "work", "kerja": return Color(hex: "8338EC")
        case "gift", "hadiah": return Color(hex: "FB5607")
        case "health", "kesehatan": return Color(hex: "06D6A0")
        case "other", "lainnya": return Color(hex: "00B4D8")
        default: return Theme.accent
        }
    }
    
    private func getIconForCategory(_ name: String) -> String {
        allCategories.first { $0.name == name }?.icon ?? "tag.fill"
    }
    
    private func saveBudget() {
        HapticManager.shared.impact(.heavy)
        let limit = CurrencyFormatter.toDouble(amount)
        
        let normalizedStart = Calendar.current.startOfDay(for: startDate)
        let normalizedEnd = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        
        if let edit = editBudget {
            // Update
            edit.limit = limit
            edit.category = selectedCategory
            edit.isRecurring = isRecurring
            edit.startDate = normalizedStart
            edit.endDate = normalizedEnd
            SyncManager.shared.enqueue(endpoint: "budgets/\(edit.id)", method: .put, body: edit.toDTO(), context: modelContext)
        } else {
            // Create
            let newBudget = Budget(category: selectedCategory, limit: limit, isRecurring: isRecurring, startDate: normalizedStart, endDate: normalizedEnd)
            modelContext.insert(newBudget)
            SyncManager.shared.enqueue(endpoint: "budgets", method: .post, body: newBudget.toDTO(), context: modelContext)
        }
        
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
        VStack(spacing: 8) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { button in
                        Button(action: { handleInput(button) }) {
                            Group {
                                if button == "delete.left" {
                                    Image(systemName: button)
                                        .font(.system(size: 16, weight: .medium))
                                } else {
                                    Text(button)
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Theme.cardBackground.opacity(0.3))
                            .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 30)
    }
    
    private func handleInput(_ symbol: String) {
        HapticManager.shared.impact(.light)
        if symbol == "delete.left" {
            if amount.count > 1 { amount.removeLast() } else { amount = "0" }
        } else if symbol == "000" {
            if amount != "0" { amount += "000" }
        } else {
            if amount == "0" { amount = symbol } else if amount.count < 12 { amount += symbol }
        }
    }
}

struct DatePickerField: View {
    let title: String
    @Binding var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
            
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .scaleEffect(0.85)
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(x: -8)
        }
        .padding(.leading, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Theme.cardBackground.opacity(0.4))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

#endif
