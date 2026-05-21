//
//  MatchVictoryScreen.swift
//  Astrocat
//
//  Created by Amanda on 20/05/26.
//

import SwiftUI
import UIKit

struct MatchVictoryScreen: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black
                    .ignoresSafeArea()

                Image("MapSpace")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(1.2)
                    .offset(y: 70)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()

                ConfettiLayer()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 10) {
                        Text("ANDREW IS THE FIRST\nCAT ON THE MOON!")
                            .font(.custom("UpheavalTT-BRK-", size: 48))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 1.0, green: 0.80, blue: 0.06))
                            .shadow(color: Color(red: 120 / 255, green: 92 / 255, blue: 9 / 255), radius: 4, x: 0, y: 3)
                        
                        Text("Tap anywhere to go back")
                            .font(.custom("Dogica", size: 13))
                            .tracking(-2.0)
                            .foregroundColor(Color.gray.opacity(0.9))
                            .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                    .padding(.top, geo.size.height * 0.18)

                    Spacer(minLength: 0)

                    ZStack(alignment: .bottom) {
                        Image("Podium")
                            .resizable()
                            .interpolation(.none)
                            .antialiased(false)
                            .scaledToFit()
                            .frame(width: geo.size.width)

                        GeometryReader { podiumGeo in
                            WinnerCatView(name: "manda", rank: 2)
                                .position(x: podiumGeo.size.width * 0.28, y: podiumGeo.size.height * 0.10)

                            WinnerCatView(name: "andrew", rank: 1)
                                .position(x: podiumGeo.size.width * 0.50, y: podiumGeo.size.height * -0.02)

                            WinnerCatView(name: "arya", rank: 3)
                                .position(x: podiumGeo.size.width * 0.72, y: podiumGeo.size.height * 0.22)

                            Text("80.00")
                                .font(.custom("Dogica", size: 11))
                                .foregroundColor(Color(red: 1.0, green: 0.80, blue: 0.06))
                                .position(x: podiumGeo.size.width * 0.28, y: podiumGeo.size.height * 0.44)

                            Text("50.00")
                                .font(.custom("Dogica", size: 11))
                                .foregroundColor(Color(red: 1.0, green: 0.80, blue: 0.06))
                                .position(x: podiumGeo.size.width * 0.49, y: podiumGeo.size.height * 0.33)

                            Text("100.00")
                                .font(.custom("Dogica", size: 11))
                                .foregroundColor(Color(red: 1.0, green: 0.80, blue: 0.06))
                                .position(x: podiumGeo.size.width * 0.71, y: podiumGeo.size.height * 0.55)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height * 0.50)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .offset(x: -10, y: 50)
            }
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture {
                navigateToMatchmakingScreen()
            }
        }
    }

    private func navigateToMatchmakingScreen() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = scene.delegate as? SceneDelegate else { return }
        delegate.navigateToMatchmakingScreen()
    }
}

private struct WinnerCatView: View {
    let name: String
    let rank: Int

    var body: some View {
        VStack(spacing: 6) {
            Text(name)
                .font(.custom("Dogica", size: 15))
                .tracking(-2.0)
                .foregroundColor(Color(red: 1.0, green: 0.80, blue: 0.06))

            Image("CatAstronaut")
                .resizable()
                .scaledToFit()
                .frame(width: rank == 1 ? 95 : 82)
        }
    }
}

private struct ConfettiLayer: View {
    //    let isAnimating: Bool
    //
    //    private let colors: [Color] = [
    //        Color(red: 1.0, green: 0.35, blue: 0.18),
    //        Color(red: 0.16, green: 0.67, blue: 1.0),
    //        Color(red: 1.0, green: 0.85, blue: 0.1),
    //        Color(red: 0.3, green: 0.93, blue: 0.42),
    //        Color(red: 0.95, green: 0.28, blue: 0.92)
    //    ]
    //
    //    var body: some View {
    //        GeometryReader { geo in
    //            ZStack {
    //                ForEach(0..<26, id: \.self) { index in
    //                    Capsule()
    //                        .fill(colors[index % colors.count])
    //                        .frame(width: CGFloat(8 + (index % 5) * 2), height: 4)
    //                        .rotationEffect(.degrees(isAnimating ? Double(180 + (index * 18)) : Double(index * 15)))
    //                        .position(
    //                            x: geo.size.width * normalizedX(index: index),
    //                            y: geo.size.height * normalizedY(index: index, isAnimating: isAnimating)
    //                        )
    //                        .opacity(0.9)
    //                }
    //            }
    //        }
    //        .allowsHitTesting(false)
    //    }
    //
    //    private func normalizedX(index: Int) -> CGFloat {
    //        let row = index % 7
    //        let lane = CGFloat(row) / 6.0
    //        return 0.08 + (0.84 * lane)
    //    }
    //
    //    private func normalizedY(index: Int, isAnimating: Bool) -> CGFloat {
    //        let base = 0.08 + (CGFloat(index / 7) * 0.11)
    //        return isAnimating ? base + 0.03 : base
    //    }
    @State private var particles: [ConfettiParticle] = []
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<particles.count, id: \.self) { index in
                    ConfettiShapeView(particle: particles[index])
                        .position(x: particles[index].x, y: particles[index].y)
                }
            }
            .onAppear {
                startConfetti(screenWidth: geo.size.width)
            }
            .onDisappear {
                stopConfetti()
            }
            .allowsHitTesting(false)
        }
    }

    private func startConfetti(screenWidth: CGFloat) {
        particles = ConfettiGenerator.generateParticles(count: 50, screenWidth: screenWidth)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            updateAnimation()
        }
    }
    
    private func updateAnimation() {
        for i in 0..<particles.count {
            ConfettiPhysics.updateParticle(&particles[i])
        }
    }
    
    private func stopConfetti() {
        timer?.invalidate()
        timer = nil
    }
}

    // MARK: - Confetti Shape Renderer
    struct ConfettiShapeView: View {
        let particle: ConfettiParticle
        
        var body: some View {
            ConfettiShape(shapeType: particle.shape)
                .fill(particle.color)
                .frame(width: 8, height: 8)
        }
    }

    // MARK: - Shape Path Builder
    struct ConfettiShape: Shape {
        let shapeType: ConfettiParticle.ConfettiShapeType
        
        func path(in rect: CGRect) -> Path {
            ConfettiShapeFactory.path(for: shapeType, in: rect)
        }
    }


#Preview {
    MatchVictoryScreen()
}
