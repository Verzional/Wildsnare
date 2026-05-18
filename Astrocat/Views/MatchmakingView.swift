//
//  MatchmakingView.swift
//  Astrocat
//
//  Created by Arya on 13/05/26.
//

import SwiftUI

struct MatchmakingView: View {
    @EnvironmentObject var matchSystem: MatchSystem

    // Floating animation state
    @State private var catOffset: CGFloat = 0
    @State private var catRotation: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: - Background
                Image("MapSpace") // full-screen space background asset
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // MARK: - Logo
                    Image("LogoAstrocat") // logo asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.82)
                        .shadow(color: .orange.opacity(0.6), radius: 12, x: 0, y: 4)
                        .padding(.bottom, 8)

                    Spacer()

                    // MARK: - AstroCat Character (floating)
                    Image("CatAstronaut") // cat character asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.52)
                        .offset(y: catOffset)
                        .rotationEffect(.degrees(catRotation))
                        .shadow(color: .white.opacity(0.15), radius: 16, x: 0, y: 8)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 2.2)
                                .repeatForever(autoreverses: true)
                            ) {
                                catOffset = -14
                                catRotation = 2.5
                            }
                        }

                    Spacer()

                    // MARK: - Buttons
                    VStack(spacing: 14) {
                        AstroCatButton(title: "QUICK MATCH") {
                            matchSystem.startMatch(mode: .quickMatch(playerCount: 2))
                        }

                        AstroCatButton(title: "INVITE FRIENDS") {
                            matchSystem.startMatch(mode: .inviteFriend(playerCount: 2))
                        }

                        AstroCatButton(title: "PLAY SOLO") {
                            matchSystem.onStartSolo?()
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 48)
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Reusable Pixel-Style Button

struct AstroCatButton: View {
    let title: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.easeIn(duration: 0.08)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeOut(duration: 0.1)) { isPressed = false }
                action()
            }
        }) {
            ZStack {
                // Button image asset (the golden pill background)
                Image("button_bg") // your button asset
                    .resizable()
                    .scaledToFill()
                    .frame(height: 62)
                    .clipped()

                // Pixel-font label
                Text(title)
                    .font(.custom("ArcadeClassic", size: 22)) // swap with your pixel font
                    .foregroundColor(.black.opacity(0.85))
                    .shadow(color: .white.opacity(0.3), radius: 0, x: 0, y: 1)
                    // Fallback if custom font not loaded:
                    // .font(.system(size: 20, weight: .black, design: .monospaced))
            }
        }
        .frame(maxWidth: .infinity)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        // Pixel-style drop shadow beneath button
        .shadow(color: .black.opacity(0.5), radius: 0, x: 4, y: 4)
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    MatchmakingView()
        .environmentObject(MatchSystem())
}
