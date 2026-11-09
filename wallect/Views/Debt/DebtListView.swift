import SwiftUI
import SwiftData

struct DebtListView: View {
    @Binding var isPresented: Bool
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Debt.dateAdded, order: .reverse) var debts: [Debt]
    
    @State private var showingAddDebt = false
    @State private var editingDebt: Debt? = nil
    @State private var filter: DebtFilter = .all
    @State private var appeared = false
    
    enum DebtFilter: String, CaseIterable {
        case all = "SEMUA"
        case debt = "PINJAM"
        case credit = "MEMINJAMKAN"
        case paid = "LUNAS"
    }
    
    var filteredDebts: [Debt] {
        switch filter {
        case .all: return debts
        case .debt: return debts.filter { $0.isDebt && !$0.isPaid }
        case .credit: return debts.filter { !$0.isDebt && !$0.isPaid }
        case .paid: return debts.filter { $0.isPaid }
        }
    }
    
    var totalHutang: Double {
        debts.filter { $0.isDebt && !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    var totalPiutang: Double {
        debts.filter { !$0.isDebt && !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundColor(Theme.textMain)
                            .frame(width: 44, height: 44)
                            .background(Theme.cardBackground.opacity(0.8))
                            .clipShape(Circle())
                    }
                    
                    Text("Pinjam & Meminjam")
                        .font(.headline)
                        .foregroundColor(Theme.textMain)
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    Button(action: {
                        HapticManager.shared.impact(.medium)
                        showingAddDebt = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title3.bold())
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                            .background(Theme.accent)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                List {
                    // Quick Stats & Filters Section
                    Section {
                        VStack(spacing: 25) {
                            HStack(spacing: 15) {
                                DebtStatBox(title: "Saya Pinjam", value: CurrencyFormatter.format(totalHutang), icon: "arrow.down.forward.circle.fill", color: Theme.expense)
                                DebtStatBox(title: "Saya Pinjamkan", value: CurrencyFormatter.format(totalPiutang), icon: "arrow.up.right.circle.fill", color: Theme.income)
                            }
                            .padding(.top, 20)
                            
                            // Filters
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(DebtFilter.allCases, id: \.self) { filterOption in
                                        FilterChip(
                                            title: filterOption.rawValue,
                                            isSelected: filter == filterOption,
                                            action: {
                                                HapticManager.shared.impact(.light)
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                    filter = filterOption
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                        .listRowSeparator(.hidden)
                    }
                    
                    // Debt Rows Section
                    Section {
                        if filteredDebts.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "banknote")
                                    .font(.system(size: 60))
                                    .foregroundColor(Theme.textSecondary.opacity(0.2))
                                
                                Text("Tidak ada catatan")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        } else {
                            ForEach(filteredDebts) { debt in
                                DebtRow(debt: debt)
                                    .onTapGesture {
                                        HapticManager.shared.impact(.light)
                                        editingDebt = debt
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            deleteDebt(debt)
                                        } label: {
                                            Label("Hapus", systemImage: "trash")
                                        }
                                        
                                        if !debt.isPaid {
                                            Button {
                                                markAsPaid(debt)
                                            } label: {
                                                Label("Selesai", systemImage: "checkmark.circle.fill")
                                            }
                                            .tint(.green)
                                        }
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                                    .listRowSeparator(.hidden)
                            }
                        }
                    }
                    
                    // Invisible footer spacer
                    Section {
                        Color.clear.frame(height: 100)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddDebt) {
            DebtEditorSheet()
                .presentationDetents([.fraction(0.85)])
        }
        .sheet(item: $editingDebt) { debt in
            DebtEditorSheet(editDebt: debt)
                .presentationDetents([.fraction(0.85)])
        }
    }
    
    private func markAsPaid(_ debt: Debt) {
        HapticManager.shared.impact(.medium)
        withAnimation {
            debt.isPaid = true
            // Sync Update
            SyncManager.shared.enqueue(endpoint: "debts", method: .post, body: debt.toDTO(), context: modelContext)
        }
    }
    
    private func deleteDebt(_ debt: Debt) {
        HapticManager.shared.impact(.medium)
        withAnimation {
            let id = debt.id
            modelContext.delete(debt)
            // Sync Delete
            SyncManager.shared.enqueue(endpoint: "debts/\(id)", method: .delete, context: modelContext)
        }
    }
}

struct DebtStatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline.bold())
                    .foregroundColor(Theme.textMain)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(Theme.cardBackground.opacity(0.4))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
