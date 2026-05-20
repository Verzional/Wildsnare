//
//  Animate.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 18/05/26.
//

import SpriteKit

enum PlayerAnimation {
    case idle
    case run
    case jump
    case dizzy
    case slimed
    
    var atlasName: String {
        switch self {
        case .idle:
            return "Idle"
        case .run:
            return "Run"
        case .jump:
            return "Jump"
        case .dizzy:
            return "Dizzy"
        case .slimed:
            return "Slimed"
        }
    }
    
    var framePrefix: String {
        switch self {
        case .idle:
            return "I"
        case .run:
            return "R"
        case .jump:
            return "J"
        case .dizzy:
            return "D"
        case .slimed:
            return "S"
        }
    }
}

extension SKAction {
    static func buildAnimation(atlasName: String, prefix: String, duration: TimeInterval = 0.1) -> SKAction {
        let atlas = SKTextureAtlas(named: atlasName)
        var frames: [SKTexture] = []
        
        let count = atlas.textureNames.count
        if count > 0 {
            for i in 1...count {
                let textureName = "\(prefix)-Frame-\(i)"
                frames.append(atlas.textureNamed(textureName))
            }
        } else {
            return SKAction.wait(forDuration: duration)
        }
        
        let animation = SKAction.animate(with: frames, timePerFrame: duration)
        return SKAction.repeatForever(animation)
    }
    
    static func playerAnimation(
        skinPrefix: String,
        animation: PlayerAnimation,
        duration: TimeInterval = 0.1
    ) -> SKAction {
        let atlasName = "\(skinPrefix)-\(animation.atlasName)"
        let prefix = "\(skinPrefix)\(animation.framePrefix)"
        
        return buildAnimation(
            atlasName: atlasName,
            prefix: prefix,
            duration: duration
        )
    }
}
