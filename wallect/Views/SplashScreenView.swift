#if !WIDGET_EXTENSION
import SwiftUI

struct SplashScreenView: View {
    @State private var logoBlur: CGFloat = 20
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.7
    @State private var nameOpacity: Double = 0
    @State private var nameOffset: CGFloat = 20
    @State private var taglineOpacity: Double = 0
    @State private var isBreathing = false
    
    // Animation States
    @State private var animateMesh = false
    @State private var shineOffset: CGFloat = -1
    @State private var ringRotation: Double = 0
    @State private var scanOffset: CGFloat = -0.1
    
    var body: some View {
        ZStack {
            // Elegant Animated Background
            animatedMeshBackground
            
            VStack(spacing: -15) {
                // Central Logo Area (Rings + Glow + Logo)
                ZStack {
                    // Orbital Rings System
                    ZStack {
                        Circle()
                            .stroke(Theme.accent.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [2, 12]))
                            .frame(width: 165, height: 165)
                            .rotationEffect(.degrees(ringRotation))
                        
                        Circle()
                            .stroke(Theme.accent.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4, 16]))
                            .frame(width: 145, height: 145)
                            .rotationEffect(.degrees(-ringRotation * 1.5))
                    }
                    .opacity(logoOpacity)
                    
                    // Subtle Outer Glow
                    Circle()
                        .fill(Theme.accent.opacity(0.15))
                        .frame(width: 155, height: 155)
                        .blur(radius: 40)
                        .scaleEffect(isBreathing ? 1.2 : 1.0)
                    
                    Theme.logoImage(size: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                        .blur(radius: logoBlur)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .overlay(
                            // Metallic Shine Effect
                            GeometryReader { geo in
                                Color.white.opacity(0.4)
                                    .mask(
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.clear, .white.opacity(0.8), .clear],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .offset(x: shineOffset * geo.size.width * 2)
                                    )
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 26))
                        )
                        .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 10)
                }
                
                VStack(spacing: 6) {
                    // Modern Branding - Simplified rendering to prevent clipping
                    Text("Wallect")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundColor(.white)
                        .opacity(nameOpacity)
                        .offset(y: nameOffset)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Funny Tagline
                    Text("For your financially unstable era")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(1.5)
                        .foregroundColor(Color.white.opacity(0.4))
                        .opacity(taglineOpacity)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .onAppear {
            startCinematicSequence()
        }
    }
    
    // MARK: - Animations
    
    private func startCinematicSequence() {
        // 1. Background & Particle Animations starts
        withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
            animateMesh.toggle()
        }
        
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
        
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false).delay(2)) {
            scanOffset = 1.2
        }
        
        // 2. Logo Blur-to-Focus
        withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
            logoBlur = 0
            logoOpacity = 1
            logoScale = 1.0
        }
        
        // 3. Shine Animation
        withAnimation(.easeInOut(duration: 1.2).delay(1.5)) {
            shineOffset = 1
        }
        
        // 4. Name Entry
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(1.0)) {
            nameOpacity = 1
            nameOffset = 0
        }
        
        // 5. Tagline Fade
        withAnimation(.easeIn(duration: 1.0).delay(1.8)) {
            taglineOpacity = 1
        }
        
        // 6. Breathing Cycle
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true).delay(1.8)) {
            isBreathing = true
        }
    }
    
    // MARK: - Background Component
    
    private var animatedMeshBackground: some View {
        ZStack {
            Color(hex: "080808").ignoresSafeArea()
            
            // Shifting Blobs
            Group {
                Circle()
                    .fill(Color.indigo.opacity(0.3))
                    .frame(width: 400, height: 400)
                    .blur(radius: 80)
                    .offset(x: animateMesh ? 100 : -100, y: animateMesh ? -150 : -200)
                
                Circle()
                    .fill(Color.cyan.opacity(0.2))
                    .frame(width: 350, height: 350)
                    .blur(radius: 90)
                    .offset(x: animateMesh ? -80 : 80, y: animateMesh ? 150 : 200)
                
                Circle()
                    .fill(Color.pink.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 70)
                    .offset(x: animateMesh ? 50 : -50, y: animateMesh ? 0 : 50)
            }
            .allowsHitTesting(false)
            
            // Vignette for depth
            RadialGradient(
                colors: [.clear, .black.opacity(0.6)],
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            // Scanning Horizon Beam
            scanningHorizon
        }
    }
    
    // MARK: - Advanced Components
    
    private var scanningHorizon: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, Theme.accent.opacity(0.08), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 2)
                .offset(y: scanOffset * geo.size.height)
                .blur(radius: 1)
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    SplashScreenView()
}

#endif
