//
//  SplashScreen.swift
//  Astrocat
//
//  Created by Amanda on 20/05/26.
//

import SwiftUI

struct SplashScreenView: View {
    
    // MARK: - Animation States
    @State private var bgOpacity: Double = 0
    
    @State private var catOffset: CGFloat = 300
    @State private var catOpacity: Double = 0
    
    @State private var sprinkleOffset: CGFloat = 300
    @State private var sprinkleOpacity: Double = 0
    
    @State private var logoOffset: CGFloat = -200
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.85
    
    @State private var presentsOpacity: Double = 0
    
    @State private var moonOpacity: Double = 0
    @State private var rockOffset: CGFloat = -70
    @State private var rockScale: CGFloat = 0.9
    @State private var rockOpacity: Double = 0
    // Callback ketika splash selesai
    var onFinished: (() -> Void)? = nil
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                // MARK: - 1. Background
                Image("Bg_Splash") // full purple asteroid scene
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .opacity(bgOpacity)
                
                Image("Moon_Splash")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .opacity(moonOpacity)
                    .offset(y: geo.size.height * -0.05)

                Image("Rocks_Splash") // full purple asteroid scene
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .opacity(rockOpacity)
                    .offset(y: rockOffset)
                    .scaleEffect(rockScale)
                
                
                // MARK: - 2. Sprinkle / Particle Trail (di belakang cat)
//                Image("Sparkle_Splash") // golden particle trail asset
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: geo.size.width * 0.55)
//                    .offset(y: sprinkleOffset)
//                    .opacity(sprinkleOpacity)
                
                // MARK: - 3. AstroCat Character
                Image("CatwithSparkle_Splash") // cat in spacesuit asset
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.6)
                    .offset(y: catOffset)
                    .opacity(catOpacity)
                
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    // MARK: - 4. "MO:S PRESENTS" label
//                    Text("MO:5 PRESENTS")
//                        .font(.custom("UpheavalTT-BRK-", size: 23)) // ganti sesuai pixel font kamu
//                        .foregroundColor(.orange)
//                        .tracking(3)
//                        .opacity(presentsOpacity)
//                        .padding(.bottom, 4)
                    
                    // MARK: - 5. ASTROCAT Logo
                    Image("Logo_Splash") // ASTROCAT logo asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.88)
                        .offset(y: logoOffset)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                    
                    Spacer()
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            runAnimationSequence()
        }
    }
    
    // MARK: - Animation Sequence
    private func runAnimationSequence() {
        let motionDuration: TimeInterval = 3.0
        let motionStart: TimeInterval = 2.2

        // Step 1: Background fade in
        withAnimation(.easeIn(duration: 0.9)) {
            bgOpacity = 1.0
        }

        // Step 2: Rock layer muncul setelah background fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            withAnimation(.easeOut(duration: 1.1)) {
                moonOpacity = 1.0
                rockOffset = 0
                rockScale = 1.2
                rockOpacity = 1.0
            }
        }

        // Step 3: Sprinkle muncul dari bawah (barengan sama cat, sedikit lebih dulu)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            withAnimation(.easeOut(duration: 0.8)) {
                sprinkleOffset = 80
                sprinkleOpacity = 1.0
            }
        }

        // Step 4: Cat naik dari bawah
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.50) {
            withAnimation(.spring(response: 0.75, dampingFraction: 0.72, blendDuration: 0)) {
                catOffset = 210
                catOpacity = 1.0
            }
        }

        // Step 5: Logo turun dari atas dengan bounce
        DispatchQueue.main.asyncAfter(deadline: .now() + motionStart) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65, blendDuration: 0)) {
                logoOffset = 0
                logoOpacity = 1.0
                logoScale = 1.0
            }
            startCatRockLogoMotion(duration: motionDuration)
        }

        // Step 6: Selesai → panggil callback ke home screen
        DispatchQueue.main.asyncAfter(deadline: .now() + motionStart + motionDuration) {
            onFinished?()
        }
    }

    private func startCatRockLogoMotion(duration: TimeInterval) {
        let stepDuration: TimeInterval = 0.7
        let steps = max(1, Int(duration / stepDuration))

        for step in 0..<steps {
            let delay = TimeInterval(step) * stepDuration
            let movingUp = step % 2 == 0

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: stepDuration)) {
                    catOffset = movingUp ? 205 : 215
                    rockOffset = movingUp ? -3 : 3
                    rockScale = movingUp ? 1.095 : 1.105
                    logoOffset = movingUp ? -2 : 2
                    logoScale = movingUp ? 0.996 : 1.004
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.easeOut(duration: 0.25)) {
                catOffset = 210
                rockOffset = 0
                rockScale = 1.1
                logoOffset = 0
                logoScale = 1.0
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SplashScreenView {
        print("Splash finished!")
    }
}
