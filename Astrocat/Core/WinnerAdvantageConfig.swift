//
//  WinnerAdvantageConfig.swift
//  Astrocat
//
//  Created by Andrew Wallace on 21/05/26.
//

import CoreGraphics
import Foundation

struct WinnerAdvantageConfig {
    let speedMultiplier: CGFloat
    let impulseMultiplier: CGFloat
    let duration: TimeInterval
}

extension WinnerAdvantageConfig {
    static let first = WinnerAdvantageConfig(
        speedMultiplier: 1.15,
        impulseMultiplier: 1.05,
        duration: 4.0
    )

    static let second = WinnerAdvantageConfig(
        speedMultiplier: 1.1,
        impulseMultiplier: 1.02,
        duration: 3.0
    )

    static let third = WinnerAdvantageConfig(
        speedMultiplier: 1.05,
        impulseMultiplier: 1.01,
        duration: 2.0
    )

    static let none = WinnerAdvantageConfig(
        speedMultiplier: 1.0,
        impulseMultiplier: 1.0,
        duration: 0
    )
    
    static let advantages: [WinnerAdvantageConfig] = [.first, .second, .third, .none]
    
    static func forRank(_ rank: Int, playerCount: Int, maxPlayers: Int = 4) -> WinnerAdvantageConfig {
        let index = maxPlayers - playerCount + rank - 1
        guard index >= 0 && index < advantages.count else { return .none }
        return advantages[index]
    }
}
