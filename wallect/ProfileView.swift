import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @ObservedObject var authManager = AppAuthManager.shared
    
    @Query var wallets: [Wallet]
    @Query var transactions: [Transaction]
    
    @State private var appeared = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navbar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundColor(Theme.textMain)
                            .frame(width: 44, height: 44)
                            .background(Theme.cardBackground.opacity(0.8))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Profil Pengguna")
                        .font(.headline)
                        .foregroundColor(Theme.textMain)
                    
                    Spacer()
                    
                    // Empty placeholder for balance layout
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        // Profile Avatar & Info
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(Theme.mainGradient)
                                    .frame(width: 100, height: 100)
                                    .shadow(color: Theme.accent.opacity(0.3), radius: 20, x: 0, y: 10)
                                
                                Text(authManager.currentUser?.name.map { String($0.prefix(1)).uppercased() } ?? "U")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                            }
                            
                            VStack(spacing: 4) {
                                Text(authManager.currentUser?.name ?? "Pengguna Wallect")
                                    .font(.title3.bold())
                                    .foregroundColor(Theme.textMain)
                                
                                Text(authManager.currentUser?.email ?? "email@example.com")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                        .padding(.top, 20)
                        .scaleEffect(appeared ? 1 : 0.9)
                        .opacity(appeared ? 1 : 0)
                        
                        // Account Statistics
                        HStack(spacing: 15) {
                            StatBox(title: "Dompet", value: "\(wallets.count)", icon: "wallet.pass.fill")
                            StatBox(title: "Transaksi", value: "\(transactions.count)", icon: "arrow.up.arrow.down.circle.fill")
                        }
                        .padding(.horizontal)
                        .offset(y: appeared ? 0 : 20)
                        .opacity(appeared ? 1 : 0)
                        
                        // Menu Sections
                        VStack(spacing: 20) {
                            ProfileMenuSection(title: "Akun & Keamanan") {
                                ProfileMenuRow(icon: "shield.fill", title: "Metode Login", value: "Google Account", color: .blue)
                                ProfileMenuRow(icon: "checkmark.seal.fill", title: "Status Akun", value: "Terverifikasi", color: .green)
                                ProfileMenuRow(icon: "icloud.and.arrow.up.fill", title: "Sinkronisasi Cloud", value: "Aktif", color: Theme.accent)
                            }
                            
                            ProfileMenuSection(title: "Aplikasi") {
                                ProfileMenuRow(icon: "bell.fill", title: "Notifikasi", value: "Aktif", color: .orange)
                                ProfileMenuRow(icon: "paintpalette.fill", title: "Tema", value: "Dark Premium", color: .purple)
                                ProfileMenuRow(icon: "info.circle.fill", title: "Tentang Wallect", value: "v1.0.0", color: .gray)
                            }
                        }
                        .padding(.horizontal)
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)
                        
                        // Logout Button
                        Button(action: { showingLogoutAlert = true }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Keluar dari Akun")
                            }
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .offset(y: appeared ? 0 : 40)
                        .opacity(appeared ? 1 : 0)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Batal", role: .cancel) { }
            Button("Logout", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("Apakah Anda yakin ingin keluar? Data lokal Anda akan dihapus demi keamanan.")
        }
    }
    
    private func performLogout() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        PersistenceService.shared.clearAllData(context: modelContext)
        authManager.logout()
        dismiss()
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Theme.accent)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.headline.bold())
                    .foregroundColor(Theme.textMain)
                Text(title)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Theme.cardBackground.opacity(0.4))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct ProfileMenuSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption.bold())
                .foregroundColor(Theme.textSecondary)
                .padding(.leading, 5)
            
            VStack(spacing: 0) {
                content
            }
            .background(Theme.cardBackground.opacity(0.4))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Theme.textMain)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Theme.textSecondary.opacity(0.5))
        }
        .padding()
    }
}

#Preview {
    ProfileView()
}
