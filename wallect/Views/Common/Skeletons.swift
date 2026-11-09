import SwiftUI

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    let duration: Double = 1.5
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.12),
                            .white.opacity(0.25),
                            .white.opacity(0.12),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: -geo.size.width + (geo.size.width * 2 * phase))
                    .onAppear {
                        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                            phase = 1
                        }
                    }
                }
            )
            .mask(content)
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Reusable Skeleton Components
struct SkeletonBox: View {
    var width: CGFloat? = nil
    var height: CGFloat
    var cornerRadius: CGFloat = 16
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.white.opacity(0.04))
            .frame(width: width, height: height)
            .shimmer()
    }
}

struct SkeletonCircle: View {
    var size: CGFloat
    
    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.04))
            .frame(width: size, height: size)
            .shimmer()
    }
}
