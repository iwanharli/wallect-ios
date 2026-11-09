import SwiftUI

struct ProfileImageView: View {
    let size: CGFloat
    @ObservedObject var authManager = AppAuthManager.shared
    
    var body: some View {
        ZStack {
            if let localImage = authManager.profileImage {
                Image(uiImage: localImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else if let email = authManager.currentUser?.email,
                      let url = email.gravatarURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                        .frame(width: size, height: size)
                        .tint(.white.opacity(0.5))
                }
            } else {
                // Initials Fallback
                ZStack {
                    Circle()
                        .fill(Theme.mainGradient)
                        .frame(width: size, height: size)
                    
                    Text(authManager.currentUser?.name.map { String($0.prefix(1)).uppercased() } ?? "U")
                        .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
            }
        }
        .frame(width: size, height: size)
        .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
    }
}
