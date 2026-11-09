import SwiftUI

struct AnalyticsSkeletonView: View {
    var body: some View {
        VStack(spacing: 32) {
            // Header Skeleton
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        SkeletonBox(width: 120, height: 10, cornerRadius: 4)
                        SkeletonBox(width: 180, height: 32, cornerRadius: 8)
                    }
                    Spacer()
                    SkeletonBox(width: 100, height: 32, cornerRadius: 10)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Summary Cards Skeleton
            HStack(spacing: 16) {
                SkeletonBox(height: 120, cornerRadius: 28)
                SkeletonBox(height: 120, cornerRadius: 28)
            }
            .padding(.horizontal, 24)
            
            // Insight Card Skeleton
            SkeletonBox(height: 140, cornerRadius: 32)
                .padding(.horizontal, 24)
            
            // Category Distribution Section
            VStack(alignment: .leading, spacing: 20) {
                SkeletonBox(width: 150, height: 12, cornerRadius: 4)
                    .padding(.horizontal, 24)
                
                SkeletonBox(height: 200, cornerRadius: 32)
                    .padding(.horizontal, 24)
            }
            
            // Top Spending Section
            VStack(alignment: .leading, spacing: 20) {
                SkeletonBox(width: 180, height: 12, cornerRadius: 4)
                    .padding(.horizontal, 24)
                
                VStack(spacing: 1) {
                    ForEach(0..<3) { _ in
                        SkeletonBox(height: 70, cornerRadius: 0)
                    }
                }
                .cornerRadius(32)
                .padding(.horizontal, 24)
            }
            
            Spacer(minLength: 120)
        }
    }
}
