import WidgetKit
import SwiftUI
import SwiftData

struct WallectEntryProvider: TimelineProvider {
    func placeholder(in context: Context) -> WallectEntry {
        WallectEntry(date: Date(), totalBalance: 5250000, monthlyIncome: 1500000, monthlyExpense: 750000)
    }

    func getSnapshot(in context: Context, completion: @escaping (WallectEntry) -> ()) {
        Task { @MainActor in
            let entry = await calculateCurrentData()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task { @MainActor in
            let entry = await calculateCurrentData()
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    @MainActor
    private func calculateCurrentData() async -> WallectEntry {
        print("DEBUG: [WallectWidget] Calculating data for widget...")
        let container = DataController.shared.container
        
        // Use a fresh context for the background fetch to avoid main thread contention
        let context = ModelContext(container)
        
        let descriptor = FetchDescriptor<Wallet>()
        let transactionDescriptor = FetchDescriptor<Transaction>()
        
        do {
            let wallets = try context.fetch(descriptor)
            let transactions = try context.fetch(transactionDescriptor)
            
            print("DEBUG: [WallectWidget] Fetched \(wallets.count) wallets and \(transactions.count) transactions.")
            
            // Break down calculation to prevent compiler timeout
            let initialBalances = wallets.reduce(0) { $0 + $1.initialBalance }
            let totalIncome = transactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
            let totalExpense = transactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
            let total = initialBalances + totalIncome - totalExpense
            
            let calendar = Calendar.current
            let income = transactions.filter {
                !$0.isExpense && !$0.isSystem && calendar.isDate($0.date, equalTo: .now, toGranularity: .month)
            }.reduce(0) { $0 + $1.amount }
            
            let expense = transactions.filter {
                $0.isExpense && !$0.isSystem && calendar.isDate($0.date, equalTo: .now, toGranularity: .month)
            }.reduce(0) { $0 + $1.amount }
            
            print("DEBUG: [WallectWidget] Calculation successful: Total \(total)")
            return WallectEntry(date: Date(), totalBalance: total, monthlyIncome: income, monthlyExpense: expense)
        } catch {
            print("ERROR: [WallectWidget] Fetch failed: \(error)")
            return WallectEntry(date: Date(), totalBalance: 0, monthlyIncome: 0, monthlyExpense: 0)
        }
    }
}

// Ensure these models exist in the target membership: Wallet, Transaction
struct WallectEntry: TimelineEntry {
    let date: Date
    let totalBalance: Double
    let monthlyIncome: Double
    let monthlyExpense: Double
}

struct WallectWidgetEntryView : View {
    var entry: WallectEntryProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        WidgetBalanceCard(
            totalBalance: entry.totalBalance,
            monthlyIncome: entry.monthlyIncome,
            monthlyExpense: entry.monthlyExpense,
            showStats: family != .systemSmall
        )
        .containerBackground(for: .widget) {
            Color.black
        }
    }
}

struct WallectWidget: Widget {
    let kind: String = "WallectWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WallectEntryProvider()) { entry in
            WallectWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Wallect Quick Glance")
        .description("Lihat saldo total dan statistik bulan ini dengan cepat.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview("Small", as: .systemSmall) {
    WallectWidget()
} timeline: {
    WallectEntry(date: .now, totalBalance: 1250000, monthlyIncome: 500000, monthlyExpense: 200000)
}

#Preview("Medium", as: .systemMedium) {
    WallectWidget()
} timeline: {
    WallectEntry(date: .now, totalBalance: 5250000, monthlyIncome: 3500000, monthlyExpense: 1200000)
}
