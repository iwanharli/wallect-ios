#if !WIDGET_EXTENSION
import SwiftUI
import SwiftData

struct BudgetHistoryView: View {
    @Binding var isPresented: Bool
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Budget.endDate, order: .reverse) var allBudgets: [Budget]
    @Query var allTransactions: [Transaction]
    @State private var selectedBudget: Budget?
    
    private var expiredBudgets: [Budget] {
        allBudgets.filter { !$0.isActive }
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
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
                        Text("Rekap Anggaran")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(Theme.accent.opacity(0.8))
                            .tracking(2)
                        Text("Histori")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 8)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if expiredBudgets.isEmpty {
                            emptyState
                        } else {
                            VStack(spacing: 16) {
                                ForEach(expiredBudgets) { budget in
                                    BudgetRow(budget: budget, transactions: allTransactions) {
                                        HapticManager.shared.impact(.medium)
                                        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                                            selectedBudget = budget
                                        }
                                    }
                                    .opacity(0.8)
                                }
                            }
                            .padding(.top)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .refreshable {
                    HapticManager.shared.impact(.medium)
                    await SyncService.shared.fetchAll(context: modelContext)
                }
            }
            
            // Nested RTL Overlay for Budget Detail from History
            if let budget = selectedBudget {
                BudgetDetailView(isPresented: Binding(
                    get: { selectedBudget != nil },
                    set: { if !$0 { selectedBudget = nil } }
                ), budget: budget)
                .transition(.move(edge: .trailing))
                .zIndex(20)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 120)
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(Theme.textSecondary.opacity(0.2))
            
            Text("Belum ada histori")
                .font(.headline)
                .foregroundColor(Theme.textSecondary)
            
            Text("Anggaran yang sudah berakhir akan otomatis masuk ke sini.")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#endif
