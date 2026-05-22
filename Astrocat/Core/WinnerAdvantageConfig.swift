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
    
    /// Returns advantage for a given rank in a match with up to 16 players.
    /// Top 25% get first-place boost, next 25% get second, next 25% get third, rest get none.
    static func forRank(_ rank: Int, playerCount: Int, maxPlayers: Int = 16) -> WinnerAdvantageConfig {
        guard playerCount > 1, rank >= 1 else { return .none }
        
        // Divide players into quartiles
        let quartileSize = max(1, playerCount / 4)
        
        if rank <= quartileSize {
            return .first
        } else if rank <= quartileSize * 2 {
            return .second
        } else if rank <= quartileSize * 3 {
            return .third
        } else {
            return .none
        }
    }
}
