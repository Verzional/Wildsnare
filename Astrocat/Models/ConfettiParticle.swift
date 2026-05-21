//
//  ConfettiParticle.swift
//  Astrocat
//
//  Created by Amanda on 20/05/26.
//


import SwiftUI
import Foundation

// MARK: - Confetti Particle Model
struct ConfettiParticle {
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let shape: ConfettiShapeType
    let driftOffset: CGFloat
    let fallSpeed: CGFloat
    
    enum ConfettiShapeType {
        case circle, square, triangle, star
    }
}

// MARK: - Confetti Colors Factory
struct ConfettiColorFactory {
    static let defaultColors: [Color] = [
        Color(red: 0.2, green: 0.47, blue: 0.22),
        Color(red: 1, green: 0.8, blue: 0),
        Color(red: 0, green: 0.8, blue: 1),
        Color(red: 1, green: 0, blue: 0.5),
        Color(red: 0.5, green: 1, blue: 0)
    ]
}

// MARK: - Confetti Shapes Factory
struct ConfettiShapeFactory {
    static let defaultShapes: [ConfettiParticle.ConfettiShapeType] = [
        .circle, .square, .triangle, .star
    ]
    
    static func path(for shape: ConfettiParticle.ConfettiShapeType, in rect: CGRect) -> Path {
        switch shape {
        case .circle:
            return Circle().path(in: rect)
        case .square:
            return Rectangle().path(in: rect)
        case .triangle:
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            return path
        case .star:
            return starPath(in: rect)
        }
    }
    
    private static func starPath(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2
        let innerRadius = radius * 0.4
        
        for i in 0..<10 {
            let angle = CGFloat(i) * .pi / 5
            let isOuter = i % 2 == 0
            let distance = isOuter ? radius : innerRadius
            let x = center.x + distance * sin(angle)
            let y = center.y - distance * cos(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Confetti Generator
struct ConfettiGenerator {
    static func generateParticles(count: Int, screenWidth: CGFloat) -> [ConfettiParticle] {
        var particles: [ConfettiParticle] = []
        
        for _ in 0..<count {
            particles.append(ConfettiParticle(
                x: CGFloat.random(in: 20...screenWidth - 20),
                y: -20,
                color: ConfettiColorFactory.defaultColors.randomElement() ?? .green,
                shape: ConfettiShapeFactory.defaultShapes.randomElement() ?? .circle,
                driftOffset: CGFloat.random(in: -0.5...0.5),
                fallSpeed: CGFloat.random(in: 120...180)
            ))
        }
        
        return particles
    }
}

// MARK: - Confetti Physics
struct ConfettiPhysics {
    static func updateParticle(_ particle: inout ConfettiParticle, deltaTime: CFTimeInterval = 1.0/60.0) {
        particle.y += particle.fallSpeed * deltaTime
        particle.x += particle.driftOffset
    }
}