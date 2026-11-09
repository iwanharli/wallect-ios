#if !WIDGET_EXTENSION
import SwiftUI
import SwiftData

struct CategoryManagerView: View {
    static var didInitialLoad = false
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Category.name) var categories: [Category]
    @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]
    @State private var showingAddCategory = false
    @State private var editingCategory: Category? = nil
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            // Base Layer: Immersive Dynamic Background
            Theme.DynamicBackground()
            
            VStack(spacing: 0) {
                // Primary Glass Header
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("KATEGORI")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(Theme.textSecondary)
                                .tracking(2)
                            Text("Manajemen")
                                .font(.system(size: 18, weight: .black))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: { 
                            HapticManager.shared.impact(.medium)
                            showingAddCategory = true 
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                Text("TAMBAH")
                                    .font(.system(size: 11, weight: .black))
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Theme.accent)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
                .background(
                    BlurView(style: .systemThinMaterialDark)
                        .ignoresSafeArea()
                )
                .overlay(
                    Rectangle()
                        .fill(Theme.glassBorder)
                        .frame(height: 1),
                    alignment: .bottom
                )
                
                if isLoading {
                    CategorySkeletonView()
                        .transition(.opacity)
                } else {
                    // Content: Custom Airy ScrollView
                    ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Pengeluaran Section
                        categorySection(title: "PENGELUARAN", items: categories.filter { $0.isExpense }, isExpense: true)
                        
                        // Pemasukan Section
                        categorySection(title: "PEMASUKAN", items: categories.filter { !$0.isExpense }, isExpense: false)
                    }
                    .padding(.top, 25)
                    .padding(.bottom, 100)
                }
                .transition(.opacity)
            }
        }
    }
        .navigationBarHidden(true)
        .onAppear {
            if CategoryManagerView.didInitialLoad {
                isLoading = false
            } else if isLoading {
                Task {
                    // Very fast shimmer for first load
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    CategoryManagerView.didInitialLoad = true
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            isLoading = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            CategoryEditorSheet()
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $editingCategory) { cat in
            CategoryEditorSheet(category: cat)
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
        }
    }
    
    @ViewBuilder
    private func categorySection(title: String, items: [Category], isExpense: Bool) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .kerning(1.5)
                    .foregroundColor(Theme.textSecondary)
                
                Spacer()
                
                Text("\(items.count) Kategori")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Theme.textSecondary.opacity(0.6))
            }
            .padding(.horizontal, 25)
            
            if items.isEmpty {
                Text("Belum ada kategori.")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .padding(.leading, 25)
            } else {
                VStack(spacing: 12) {
                    ForEach(items) { cat in
                        CategoryPremiumCard(category: cat, transactions: transactions)
                            .onTapGesture {
                                editingCategory = cat
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteCategory(cat)
                                } label: {
                                    Label("Hapus Kategori", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private func deleteCategory(_ cat: Category) {
        let categoryId = cat.id
        modelContext.delete(cat)
        SyncManager.shared.enqueue(endpoint: "categories/\(categoryId)", method: .delete, context: modelContext)
        HapticManager.shared.impact(.medium)
    }
}

struct CategoryPremiumCard: View {
    let category: Category
    let transactions: [Transaction]
    @State private var isPressed = false
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: category.hexColor).opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: category.icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: category.hexColor))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(category.isExpense ? "Pengeluaran" : "Pemasukan")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Theme.textSecondary.opacity(0.3))
            }
        }
        .padding(18)
        .background(
            ZStack {
                Theme.cardBackground.opacity(0.4)
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Theme.glassBorder, lineWidth: 1)
                
                // Subtle gradient based on category color
                LinearGradient(colors: [Color(hex: category.hexColor).opacity(0.05), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .cornerRadius(24)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .scaleEffect(isPressed ? 0.98 : 1.0)
    }
}

struct CategoryEditorSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    var category: Category? = nil
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "fork.knife"
    @State private var selectedColor: String = "A8DADC"
    @State private var isExpense: Bool = true
    
    let colors = [
        "FF9F1C", "FF006E", "3A86FF", "8338EC", "FB5607", 
        "06D6A0", "00B4D8", "E63946", "A8DADC", 
        "457B9D", "2A9D8F", "E9C46A", "F4A261", "E76F51"
    ]
    
    let icons = [
        "fork.knife", "cart.fill", "car.fill", "gamecontroller.fill", 
        "briefcase.fill", "gift.fill", "heart.fill", "house.fill",
        "bag.fill", "creditcard.fill", "cross.case.fill", "airplane",
        "star.fill", "book.fill", "hammer.fill", "music.note"
    ]
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Sheet Title
                Text(category == nil ? "Tambah Kategori" : "Edit Kategori")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Theme.textMain)
                    .padding(.top, 25)
                
                // Real-time Preview Card
                VStack(spacing: 12) {
                    Text("PRATINJAU")
                        .font(.system(size: 10, weight: .bold))
                        .kerning(1)
                        .foregroundColor(Theme.textSecondary)
                    
                    CategoryPremiumCard(category: Category(name: name.isEmpty ? "Nama Kategori" : name, 
                                                                  icon: selectedIcon, 
                                                                  hexColor: selectedColor, 
                                                                  isExpense: isExpense), transactions: [])
                        .padding(.horizontal, 25)
                }
                .padding(.bottom, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Name Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NAMA KATEGORI")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Theme.textSecondary)
                            
                            TextField("Contoh: Hobi, Zakat", text: $name)
                                .padding()
                                .background(Theme.cardBackground)
                                .cornerRadius(15)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Theme.glassBorder, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                        
                        if category == nil {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("JENIS KATEGORI")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Theme.textSecondary)
                                Picker("Type", selection: $isExpense) {
                                    Text("Pengeluaran").tag(true)
                                    Text("Pemasukan").tag(false)
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Icon Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PILIH IKON")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Theme.textSecondary)
                            
                            let columns = [GridItem(.adaptive(minimum: 44))]
                            LazyVGrid(columns: columns, spacing: 15) {
                                ForEach(icons, id: \.self) { icon in
                                    Button(action: { 
                                        selectedIcon = icon 
                                        HapticManager.shared.impact(.light)
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(selectedIcon == icon ? Color(hex: selectedColor) : Theme.cardBackground)
                                                .frame(width: 44, height: 44)
                                            
                                            Image(systemName: icon)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(selectedIcon == icon ? (Color(hex: selectedColor).isLight ? .black : .white) : Theme.textMain.opacity(0.6))
                                        }
                                        .overlay(
                                            Circle()
                                                .stroke(selectedIcon == icon ? Color.white.opacity(0.2) : Theme.glassBorder, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Color Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PILIH WARNA")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Theme.textSecondary)
                            
                            let colorCols = [GridItem(.adaptive(minimum: 36))]
                            LazyVGrid(columns: colorCols, spacing: 15) {
                                ForEach(colors, id: \.self) { hex in
                                    Button(action: { 
                                        selectedColor = hex 
                                        HapticManager.shared.impact(.light)
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: hex))
                                                .frame(width: 36, height: 36)
                                            
                                            if selectedColor == hex {
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 2)
                                                    .frame(width: 44, height: 44)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 25)
                }
                
                // Save Button
                Button(action: save) {
                    Text(category == nil ? "Tambahkan Kategori" : "Simpan Perubahan")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.accent)
                        .cornerRadius(18)
                        .shadow(color: Theme.accent.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 25)
                .disabled(name.isEmpty)
                .opacity(name.isEmpty ? 0.5 : 1)
            }
        }
        .onAppear {
            if let cat = category {
                name = cat.name
                selectedIcon = cat.icon
                selectedColor = cat.hexColor
                isExpense = cat.isExpense
            }
        }
    }
    
    private func save() {
        HapticManager.shared.impact(.medium)
        
        if let cat = category {
            let oldName = cat.name
            let newName = name
            
            // Update Category
            cat.name = newName
            cat.icon = selectedIcon
            cat.hexColor = selectedColor
            
            // Cascading Updates: Transactions
            let txFetch = FetchDescriptor<Transaction>(predicate: #Predicate { $0.category == oldName })
            if let transactions = try? modelContext.fetch(txFetch) {
                for tx in transactions {
                    tx.category = newName
                    tx.syncStatus = "pending"
                    SyncManager.shared.enqueue(endpoint: "transactions/\(tx.id)", method: .patch, body: tx.toDTO(), context: modelContext)
                }
            }
            
            // Cascading Updates: Budgets
            let budgetFetch = FetchDescriptor<Budget>(predicate: #Predicate { $0.category == oldName })
            if let budgets = try? modelContext.fetch(budgetFetch) {
                for budget in budgets {
                    budget.category = newName
                    budget.syncStatus = "pending"
                    SyncManager.shared.enqueue(endpoint: "budgets/\(budget.id)", method: .patch, body: budget.toDTO(), context: modelContext)
                }
            }
            
            SyncManager.shared.enqueue(endpoint: "categories/\(cat.id)", method: .patch, body: cat.toDTO(), context: modelContext)
        } else {
            let newCat = Category(name: name, icon: selectedIcon, hexColor: selectedColor, isExpense: isExpense)
            modelContext.insert(newCat)
            SyncManager.shared.enqueue(endpoint: "categories", method: .post, body: newCat.toDTO(), context: modelContext)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    CategoryManagerView()
}

#endif
