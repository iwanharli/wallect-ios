import SwiftUI

struct HomeSkeletonView: View {
    var body: some View {
        VStack(spacing: 25) {
            // Unified Header Skeleton (Match UnifiedHeaderCard)
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        SkeletonBox(width: 80, height: 10, cornerRadius: 4)
                        SkeletonBox(width: 140, height: 20, cornerRadius: 6)
                    }
                    Spacer()
                    SkeletonCircle(size: 44)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    SkeletonBox(width: 100, height: 10, cornerRadius: 4)
                    SkeletonBox(width: 200, height: 36, cornerRadius: 8)
                }
                
                HStack(spacing: 30) {
                    VStack(alignment: .leading, spacing: 6) {
                        SkeletonBox(width: 40, height: 8, cornerRadius: 3)
                        SkeletonBox(width: 80, height: 12, cornerRadius: 4)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        SkeletonBox(width: 40, height: 8, cornerRadius: 3)
                        SkeletonBox(width: 80, height: 12, cornerRadius: 4)
                    }
                    Spacer()
                }
            }
            .padding(25)
            .background(Color.white.opacity(0.04))
            .cornerRadius(32)
            .padding(.horizontal)
            
            // Goals Section Skeleton
            VStack(alignment: .leading, spacing: 15) {
                SkeletonBox(width: 100, height: 14, cornerRadius: 4)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<3) { _ in
                            SkeletonBox(width: 160, height: 110, cornerRadius: 24)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Budgets Section Skeleton
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    SkeletonBox(width: 120, height: 14, cornerRadius: 4)
                    Spacer()
                    SkeletonCircle(size: 32)
                    SkeletonCircle(size: 32)
                }
                .padding(.horizontal)
                
                VStack(spacing: 16) {
                    ForEach(0..<2) { _ in
                        SkeletonBox(height: 70, cornerRadius: 24)
                            .padding(.horizontal)
                    }
                }
            }
            
            // Transactions Skeleton
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    SkeletonBox(width: 140, height: 14, cornerRadius: 4)
                    Spacer()
                    SkeletonBox(width: 80, height: 24, cornerRadius: 10)
                }
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ForEach(0..<4) { _ in
                        HStack(spacing: 16) {
                            SkeletonCircle(size: 44)
                            VStack(alignment: .leading, spacing: 8) {
                                SkeletonBox(width: 120, height: 12, cornerRadius: 4)
                                SkeletonBox(width: 70, height: 10, cornerRadius: 3)
                            }
                            Spacer()
                            SkeletonBox(width: 90, height: 14, cornerRadius: 4)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            Spacer(minLength: 120)
        }
        .padding(.top, 20)
    }
}
