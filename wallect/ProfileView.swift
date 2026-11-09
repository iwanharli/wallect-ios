#if !WIDGET_EXTENSION
import SwiftUI
import SwiftData
import PhotosUI

struct ProfileView: View {
    @Binding var isPresented: Bool
    @Environment(\.modelContext) var modelContext
    @ObservedObject var authManager = AppAuthManager.shared
    
    @Query var wallets: [Wallet]
    @Query var transactions: [Transaction]
    
    @AppStorage("isDebtFeatureEnabled") var isDebtFeatureEnabled = false
    
    @State private var appeared = false
    @State private var showingLogoutAlert = false
    @State private var showingResetAlert = false
    @State private var isResetting = false
    @State private var showingQRScanner = false
    
    // Photo Selection
    @State private var photoItem: PhotosPickerItem?
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navbar
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
                            ZStack(alignment: .bottomTrailing) {
                                ZStack {
                                    ProfileImageView(size: 100)
                                }
                                
                                // Interactive Camera Picker Overlay
                                PhotosPicker(selection: $photoItem, matching: .images) {
                                    ZStack {
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 32, height: 32)
                                            .shadow(color: .black.opacity(0.2), radius: 5)
                                        
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                    }
                                }
                                .buttonStyle(.plain)
                                .offset(x: -2, y: -2)
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
                                
                                // Face ID / Touch ID Toggle
                                HStack(spacing: 15) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.purple.opacity(0.15))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: BiometricAuthService.shared.biometricType == .faceID ? "faceid" : "touchid")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.purple)
                                    }
                                    
                                    Text(BiometricAuthService.shared.biometricType == .faceID ? "Kunci Face ID" : "Kunci Touch ID")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.textMain)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $authManager.isBiometricEnabled)
                                        .toggleStyle(SwitchToggleStyle(tint: Theme.accent))
                                        .labelsHidden()
                                }
                                .padding()
                                
                                ProfileMenuRow(icon: "checkmark.seal.fill", title: "Status Akun", value: "Terverifikasi", color: .green)
                                
                                // QR Login scanner
                                Button(action: { showingQRScanner = true }) {
                                    HStack(spacing: 15) {
                                        ZStack {
                                            Circle()
                                                .fill(Theme.accent.opacity(0.15))
                                                .frame(width: 32, height: 32)
                                            Image(systemName: "qrcode.viewfinder")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(Theme.accent)
                                        }
                                        
                                        Text("Scan Login Web")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.textMain)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(Theme.textSecondary.opacity(0.5))
                                    }
                                    .padding()
                                }
                                .fullScreenCover(isPresented: $showingQRScanner) {
                                    QRScannerView(isPresented: $showingQRScanner)
                                }
                                
                                ProfileMenuRow(icon: "icloud.and.arrow.up.fill", title: "Sinkronisasi Cloud", value: "Aktif", color: Theme.accent)
                            }
                            
                            ProfileMenuSection(title: "Aplikasi") {
                                ProfileMenuRow(icon: "bell.fill", title: "Notifikasi", value: "Aktif", color: .orange)
                                ProfileMenuRow(icon: "paintpalette.fill", title: "Tema", value: "Dark Premium", color: .purple)
                                
                                // New Debt Feature Toggle
                                HStack(spacing: 15) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.cyan.opacity(0.15))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "banknote.fill")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.cyan)
                                    }
                                    
                                    Text("Pinjam & Meminjam")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.textMain)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $isDebtFeatureEnabled)
                                        .toggleStyle(SwitchToggleStyle(tint: Theme.accent))
                                        .labelsHidden()
                                }
                                .padding()
                                
                                ProfileMenuRow(icon: "info.circle.fill", title: "Tentang Wallect", value: "v1.0.0", color: .gray)
                            }
                        }
                        .padding(.horizontal)
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)
                        .padding(.horizontal)
                        
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
                        
                        // Danger Zone
                        ProfileMenuSection(title: "ZONA BAHAYA") {
                            VStack(spacing: 12) {
                                Button(action: { showingResetAlert = true }) {
                                    HStack {
                                        if isResetting {
                                            ProgressView()
                                                .tint(.white)
                                                .padding(.trailing, 8)
                                        } else {
                                            Image(systemName: "trash.fill")
                                        }
                                        Text("Hapus Semua Data")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(15)
                                }
                                .disabled(isResetting)
                                
                                Text("Penghapusan ini bersifat permanen dan akan menghapus semua Dompet, Transaksi, dan Anggaran Kamu di cloud & lokal.")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding()
                        }
                        .padding(.horizontal)
                        .padding(.top, 30)
                        
                        // Stats or footer spacer
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
            Text("Apakah Kamu yakin ingin keluar? Data lokal Kamu akan dihapus demi keamanan.")
        }
        .alert("Hapus Semua Data?", isPresented: $showingResetAlert) {
            Button("Batal", role: .cancel) { }
            Button("Hapus Permanen", role: .destructive) {
                performReset()
            }
        } message: {
            Text("Tindakan ini tidak bisa dibatalkan. Seluruh histori keuangan Kamu akan dihapus selamanya.")
        }
        .onChange(of: photoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    authManager.saveLocalProfileImage(data: data)
                }
            }
        }
    }
    
    private func performLogout() {
        HapticManager.shared.impact(.medium)
        PersistenceService.shared.clearAllData(context: modelContext)
        authManager.logout()
        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
            isPresented = false
        }
    }
    
    private func performReset() {
        HapticManager.shared.impact(.heavy)
        isResetting = true
        
        Task {
            do {
                try await SyncService.shared.resetAllData(context: modelContext)
                isResetting = false
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                    isPresented = false
                }
            } catch {
                print("Failed to reset: \(error)")
                isResetting = false
            }
        }
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
    ProfileView(isPresented: .constant(true))
}

#endif
