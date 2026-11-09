import SwiftUI

struct CategorySkeletonView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header Skeleton
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        SkeletonBox(width: 80, height: 10, cornerRadius: 4)
                        SkeletonBox(width: 140, height: 18, cornerRadius: 8)
                    }
                    Spacer()
                    SkeletonBox(width: 100, height: 32, cornerRadius: 10)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .background(Color.white.opacity(0.04))
            
            // Content Skeleton
            ScrollView(showsIndicators: false) {
                VStack(spacing: 35) {
                    ForEach(0..<2) { _ in
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                SkeletonBox(width: 120, height: 10, cornerRadius: 4)
                                Spacer()
                                SkeletonBox(width: 60, height: 8, cornerRadius: 4)
                            }
                            .padding(.horizontal, 25)
                            
                            VStack(spacing: 12) {
                                ForEach(0..<3) { _ in
                                    HStack(spacing: 16) {
                                        SkeletonCircle(size: 48)
                                        VStack(alignment: .leading, spacing: 8) {
                                            SkeletonBox(width: 140, height: 14, cornerRadius: 4)
                                            SkeletonBox(width: 80, height: 10, cornerRadius: 4)
                                        }
                                        Spacer()
                                        SkeletonCircle(size: 16)
                                    }
                                    .padding(18)
                                    .background(Color.white.opacity(0.04))
                                    .cornerRadius(24)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.top, 25)
                .padding(.bottom, 100)
            }
            .scrollDisabled(true)
        }
    }
}
