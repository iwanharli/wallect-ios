import SwiftUI
import SwiftData

struct CategoryManagerView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Category.name) var categories: [Category]
    @State private var showingAddCategory = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundColor(Theme.textMain)
                    }
                    Spacer()
                    Text("Kelola Kategori")
                        .font(.headline)
                        .foregroundColor(Theme.textMain)
                    Spacer()
                    Button(action: { showingAddCategory = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(Theme.accent)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                List {
                    Section(header: Text("PENGELUARAN").foregroundColor(Theme.textSecondary).font(.caption)) {
                        ForEach(categories.filter { $0.isExpense }) { cat in
                            CategoryRow(category: cat)
                        }
                        .onDelete { indexSet in
                            deleteCategory(at: indexSet, isExpense: true)
                        }
                    }
                    .listRowBackground(Theme.cardBackground.opacity(0.4))
                    
                    Section(header: Text("PEMASUKAN").foregroundColor(Theme.textSecondary).font(.caption)) {
                        ForEach(categories.filter { !$0.isExpense }) { cat in
                            CategoryRow(category: cat)
                        }
                        .onDelete { indexSet in
                            deleteCategory(at: indexSet, isExpense: false)
                        }
                    }
                    .listRowBackground(Theme.cardBackground.opacity(0.4))
                }
                .scrollContentBackground(.hidden)
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategorySheet()
                .presentationDetents([.height(400)])
        }
    }
    
    private func deleteCategory(at indexSet: IndexSet, isExpense: Bool) {
        let filteredList = categories.filter { $0.isExpense == isExpense }
        for index in indexSet {
            let cat = filteredList[index]
            let categoryId = cat.id
            modelContext.delete(cat)
            SyncManager.shared.enqueue(endpoint: "categories/\(categoryId)", method: .delete, context: modelContext)
        }
    }
}

struct CategoryRow: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(Theme.cardBackground)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: category.icon)
                        .font(.caption)
                        .foregroundColor(Theme.accent)
                )
            
            Text(category.name)
                .font(.subheadline)
                .foregroundColor(Theme.textMain)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct AddCategorySheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "dollarsign.circle"
    @State private var isExpense: Bool = true
    
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
                Text("Tambah Kategori")
                    .font(.headline)
                    .foregroundColor(Theme.textMain)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nama Kategori")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    TextField("Contoh: Hobi, Zakat", text: $name)
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                HStack(spacing: 20) {
                    Picker("Type", selection: $isExpense) {
                        Text("Pengeluaran").tag(true)
                        Text("Pemasukan").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Pilih Ikon")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(icons, id: \.self) { icon in
                                Button(action: { selectedIcon = icon }) {
                                    Circle()
                                        .fill(selectedIcon == icon ? Theme.accent : Theme.cardBackground)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Image(systemName: icon)
                                                .foregroundColor(selectedIcon == icon ? .black : .white)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Button(action: save) {
                    Text("Simpan Kategori")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accent)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                .disabled(name.isEmpty)
                .opacity(name.isEmpty ? 0.5 : 1)
            }
        }
    }
    
    private func save() {
        let newCat = Category(name: name, icon: selectedIcon, isExpense: isExpense)
        modelContext.insert(newCat)
        SyncManager.shared.enqueue(endpoint: "categories", method: .post, body: newCat.toDTO(), context: modelContext)
        dismiss()
    }
}

#Preview {
    CategoryManagerView()
}
