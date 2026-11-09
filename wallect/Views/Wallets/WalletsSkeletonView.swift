import SwiftUI

struct WalletsSkeletonView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header Summary Card Skeleton
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        SkeletonBox(width: 120, height: 10, cornerRadius: 4)
                        SkeletonBox(width: 180, height: 28, cornerRadius: 8)
                    }
                    Spacer()
                    HStack(spacing: 12) {
                        SkeletonCircle(size: 50)
                        SkeletonCircle(size: 50)
                    }
                }
            }
            .padding(24)
            .background(Color.white.opacity(0.04))
            .cornerRadius(32)
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)
            
            // Custom Segmented Picker Skeleton
            HStack(spacing: 0) {
                ForEach(0..<2) { _ in
                    VStack(spacing: 8) {
                        SkeletonBox(width: 60, height: 12, cornerRadius: 6)
                        SkeletonBox(width: 40, height: 3, cornerRadius: 1.5)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            
            // Grid Part (Wallets)
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(0..<4) { _ in
                        SkeletonBox(height: 110, cornerRadius: 24)
                    }
                }
                .padding(.horizontal, 24)
                
                // Goal list skeleton (for the second tab logic)
                VStack(spacing: 16) {
                    SkeletonBox(width: 150, height: 10, cornerRadius: 4)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(0..<2) { _ in
                        SkeletonBox(height: 120, cornerRadius: 24)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 32)
                
                Spacer(minLength: 120)
            }
            .scrollDisabled(true)
        }
    }
}
