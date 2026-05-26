//
//  MatchLobbyOverlay.swift
//  Astrocat
//

import SwiftUI

struct MatchLobbyOverlay: View {
    let playerCount: Int
    
    @State private var dotCount: Int = 0
    @State private var catFloat: CGFloat = 0
    @State private var dotTimer: Timer?
    
    private var dotsText: String {
        String(repeating: ".", count: dotCount)
    }
    
    var body: some View {
        ZStack {
            // Full-screen dimmed background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Floating cat
                Image("CatAstronaut")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                    .offset(y: catFloat)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 1.8)
                            .repeatForever(autoreverses: true)
                        ) {
                            catFloat = -15
                        }
                    }
                
                // Status text
                VStack(spacing: 12) {
                    Text("WAITING FOR PLAYERS\(dotsText)")
                        .font(.custom("UpheavalTT-BRK-", size: 32))
                        .foregroundColor(Color(red: 1.0, green: 0.80, blue: 0.06))
                        .shadow(color: Color(red: 120 / 255, green: 92 / 255, blue: 9 / 255), radius: 4, x: 0, y: 3)
                    
                    if playerCount > 0 {
                        Text("\(playerCount) player\(playerCount == 1 ? "" : "s") ready")
                            .font(.custom("Dogica", size: 13))
                            .tracking(-1.5)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                // Loading indicator
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color(red: 1.0, green: 0.80, blue: 0.06))
                            .frame(width: 10, height: 10)
                            .scaleEffect(dotCount == index + 1 ? 1.4 : 0.8)
                            .opacity(dotCount == index + 1 ? 1.0 : 0.4)
                            .animation(.easeInOut(duration: 0.3), value: dotCount)
                    }
                }
                
                Spacer()
                
                Text("Game starts when all players are ready")
                    .font(.custom("Dogica", size: 11))
                    .tracking(-1.5)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            startDotAnimation()
        }
        .onDisappear {
            stopDotAnimation()
        }
    }
    
    private func startDotAnimation() {
        stopDotAnimation()
        dotTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            dotCount = (dotCount % 3) + 1
        }
    }
    
    private func stopDotAnimation() {
        dotTimer?.invalidate()
        dotTimer = nil
    }
}

#Preview {
    MatchLobbyOverlay(playerCount: 3)
}
