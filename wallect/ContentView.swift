import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showingAddTransaction = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content Switcher
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .analytics:
                    AnalyticsView()
                case .wallets:
                    WalletsView()
                case .settings:
                    SettingsView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.2), value: selectedTab)
            
            // Premium Bottom Navigation Bar
            BottomNavBar(selectedTab: $selectedTab, showingAddTransaction: $showingAddTransaction)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
        }
    }
}

struct BottomNavBar: View {
    @Binding var selectedTab: Tab
    @Binding var showingAddTransaction: Bool
    @State private var pulsing = false
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                if tab == .add {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showingAddTransaction.toggle()
                    }) {
                        Circle()
                            .fill(Theme.accent)
                            .frame(width: 52, height: 52)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.title3.bold())
                                    .foregroundColor(.black)
                            )
                            .scaleEffect(pulsing ? 1.07 : 1.0)
                            .shadow(color: Theme.accent.opacity(pulsing ? 0.55 : 0.3), radius: pulsing ? 15 : 10, x: 0, y: 5)
                    }
                    .offset(y: -15)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                            pulsing = true
                        }
                    }
                } else {
                    // Regular Tab Button
                    Spacer()
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.rawValue)
                                .font(.system(size: 18))
                                .foregroundColor(selectedTab == tab ? Theme.accent : Theme.textSecondary)
                            
                            Text(tab.title)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(selectedTab == tab ? Theme.accent : Theme.textSecondary)
                        }
                        .frame(width: 60)
                    }
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            ZStack {
                // Blur Effect (Glassmorphism)
                BlurView(style: .systemThinMaterialDark)
                    .clipShape(Capsule())
                
                // Outer Stroke
                Capsule()
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
        )
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
        .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
    }
}

// Helper for UIKit Blur Effect in SwiftUI
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Transaction.self, configurations: config)
    
    return ContentView()
        .modelContainer(container)
}
