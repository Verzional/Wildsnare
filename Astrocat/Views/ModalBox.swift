//
//  ModalBox.swift
//  Astrocat
//
//  Created by Matthew Sebastian Lesmana on 19/05/26.
//

import SwiftUI

struct ModalBox<Content: View>: View {
    // Controls whether the modal is visible
    @Binding var isShowing: Bool
    
    // Allows you to pass any SwiftUI view inside the modal
    @ViewBuilder let content: Content
    
    var body: some View {
        ZStack {
            if isShowing {
                // 1. The semi-transparent background
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Optional: Tap the background to dismiss
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            isShowing = false
                        }
                    }
                    // A simple fade for the background looks best
                    .transition(.opacity)
                    .zIndex(1)
                
                // 2. The actual pop-up content
                content
                    // The scale transition for the "pop" effect
                    .transition(.scale(scale: 0.1, anchor: .center))
                    .zIndex(2)
            }
        }
    }
}

struct GameView: View {
    @State private var showLeaderboard = false
    @State private var showPauseMenu = false
    
    var body: some View {
        ZStack {
            // --- YOUR MAIN GAME UI ---
            VStack(spacing: 20) {
                Text("Epic Game")
                    .font(.largeTitle)
                
                Button("End Game (Show Leaderboard)") {
                    // Trigger the modal with a bouncy spring animation
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                        showLeaderboard = true
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Pause Game") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                        showPauseMenu = true
                    }
                }
            }
            
            // --- YOUR LEADERBOARD MODAL ---
            ModalBox(isShowing: $showLeaderboard) {
                // Put your custom PNG inside the closure
                Image("YourLeaderboardImageName") // Replace with your asset name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320)
                    .shadow(radius: 20)
                    
                    // Optional: Add an overlay button to close it from the inside
                    .overlay(alignment: .topTrailing) {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                showLeaderboard = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
            }
            
            // --- YOUR PAUSE MENU MODAL ---
            ModalBox(isShowing: $showPauseMenu) {
                // You can pass entirely different content here later!
                VStack {
                    Text("PAUSED")
                        .font(.title).bold()
                        .foregroundColor(.white)
                    // Add your pause buttons here...
                }
                .frame(width: 250, height: 300)
                .background(Color.blue.cornerRadius(20))
            }
        }
    }
}

#Preview {
    // 1. We use .constant(true) as a dummy switch to force the preview to stay open
    ModalBox(isShowing: .constant(true)) {
        
        // 2. We put your custom PNG inside the content curly braces { }
        Image("BoxModal")
            .resizable()
            .scaledToFit()
            .frame(width: 320)
    }
}
