import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: Tab = .home
    @State private var showingAddTransaction = false
    @StateObject private var navigationState = NavigationState()
    
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
                case .categories:
                    CategoryManagerView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.2), value: selectedTab)
            
            // Premium Bottom Navigation Bar
            if !navigationState.isTabBarHidden {
                BottomNavBar(selectedTab: $selectedTab, showingAddTransaction: $showingAddTransaction)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(100)
            }
        }
        .environmentObject(navigationState)
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                // Force dismiss keyboard when app goes to background
                #if !WIDGET_EXTENSION
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                #endif
            }
        }
    }
}

struct BottomNavBar: View {
    @Binding var selectedTab: Tab
    @Binding var showingAddTransaction: Bool
    @State private var pulsing = false
    
    var body: some View {
        GeometryReader { proxy in
            let totalWidth = proxy.size.width
            let tabCount = CGFloat(Tab.allCases.count)
            let itemWidth = totalWidth / tabCount
            
            ZStack(alignment: .leading) {
                // Background Glass
                ZStack {
                    BlurView(style: .systemThinMaterialDark)
                        .clipShape(Capsule())
                    
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)], 
                                startPoint: .topLeading, 
                                endPoint: .bottomTrailing
                            ), 
                            lineWidth: 1
                        )
                }
                .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
                
                // Sliding Highlight Indicator
                let activeIndex = CGFloat(Tab.allCases.firstIndex(of: selectedTab) ?? 0)
                let indicatorOffset = activeIndex * itemWidth
                
                ZStack {
                    // Ambient Glow
                    Capsule()
                        .fill(Theme.accent.opacity(0.15))
                        .blur(radius: 8)
                    
                    // Main Highlight
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Theme.accent.opacity(0.1), Theme.accent.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .frame(width: itemWidth - 16, height: 44)
                .offset(x: indicatorOffset + 8)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedTab)
                
                // Tabs
                HStack(spacing: 0) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        if tab == .add {
                            // Central Smart Add Button
                            Button(action: {
                                HapticManager.shared.impact(.heavy)
                                showingAddTransaction.toggle()
                            }) {
                                ZStack {
                                    // Outer tactical pulse
                                    Circle()
                                        .stroke(Theme.accent.opacity(pulsing ? 0.4 : 0.1), lineWidth: 2)
                                        .frame(width: 58, height: 58)
                                        .scaleEffect(pulsing ? 1.15 : 1.0)
                                        .opacity(pulsing ? 0 : 1)
                                    
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Theme.accent, Theme.accent.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 52, height: 52)
                                        .overlay(
                                            Image(systemName: "plus")
                                                .font(.title3.bold())
                                                .foregroundColor(.black)
                                                .rotationEffect(.degrees(showingAddTransaction ? 45 : 0))
                                        )
                                }
                                .shadow(color: Theme.accent.opacity(0.3), radius: pulsing ? 15 : 10, x: 0, y: 5)
                            }
                            .offset(y: -15)
                            .frame(width: itemWidth)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                                    pulsing = true
                                }
                            }
                        } else {
                            // Regular Tab with Micro-Animations
                            Button(action: {
                                HapticManager.shared.impact(.light)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = tab
                                }
                            }) {
                                Image(systemName: tab.rawValue)
                                    .font(.system(size: 20))
                                    .symbolVariant(selectedTab == tab ? .fill : .none)
                                    .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                                    .foregroundColor(selectedTab == tab ? Theme.accent : Theme.textSecondary)
                                    .frame(width: itemWidth, height: 64)
                                    .contentShape(Rectangle())
                            }
                        }
                    }
                }
            }
        }
        .frame(height: 64)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
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
