//
//  RoundConfig.swift
//  Astrocat
//
//  Created by Andrew Wallace on 20/05/26.
//

import CoreGraphics

struct RoundConfig {
    let platformTexture: String
    let backgroundTexture: String
    let playerSkinPrefix: String
}

extension RoundConfig {
    static let earth = RoundConfig(
        platformTexture: "PlatformEarth",
        backgroundTexture: "MapEarth",
        playerSkinPrefix: "N"
    )
    
    static let sky = RoundConfig(
        platformTexture: "PlatformSky",
        backgroundTexture: "MapSky",
        playerSkinPrefix: "J"
    )
    
    static let space = RoundConfig(
        platformTexture: "PlatformMoon",
        backgroundTexture: "MapSpace",
        playerSkinPrefix: "A"
    )
    
    static let allRounds: [RoundConfig] = [.earth, .sky, .space]
}
