import SwiftUI

struct SettingsView: View {
    @AppStorage("userName") private var userName: String = "User"
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    Text("Pengaturan")
                        .font(.title2.bold())
                        .foregroundColor(Theme.textMain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Profile Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Profil")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                        
                        HStack {
                            Circle()
                                .fill(Theme.glassGradient)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white)
                                        .font(.title3)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Nama Tampilan")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                                TextField("Nama Anda", text: $userName)
                                    .font(.subheadline.bold())
                                    .foregroundColor(Theme.textMain)
                            }
                            .padding(.leading, 8)
                        }
                        .padding()
                        .background(Theme.cardBackground.opacity(0.5))
                        .cornerRadius(18)
                    }
                    .padding(.horizontal)
                    
                    // Info Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Tentang")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(Theme.accent)
                            Text("Wallect v1.0")
                                .font(.subheadline)
                                .foregroundColor(Theme.textMain)
                            Spacer()
                        }
                        .padding()
                        .background(Theme.cardBackground.opacity(0.5))
                        .cornerRadius(18)
                    }
                    .padding(.horizontal)
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 120)
                }
                .padding(.top, 40)
            }
        }
    }
}

#Preview {
    SettingsView()
}
