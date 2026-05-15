//
//  TrapComponent.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 08/05/26.
//

import GameplayKit
import SpriteKit

class TrapComponent: GKComponent {
    let type: TrapType
    
    private var spriteNode: SKSpriteNode? {
        return entity?.component(ofType: GKSKNodeComponent.self)?.node as? SKSpriteNode
    }
    
    // Cooldown
    var cooldown: TimeInterval = 3.0
    var lastActivationTime: TimeInterval = 0.0
    var isOnCooldown: Bool = false {
        didSet {
            if isOnCooldown {
                spriteNode?.shader = Shaders.grayscaleShader
            } else {
                spriteNode?.shader = nil
            }
        }
    }
    
    // Black Hole
    var radius: CGFloat = 150.0
    var pullForce: CGFloat = 1000.0
    
    // Force Field
    var impulseForce: CGFloat = 100.0
    var repelDuration: TimeInterval = 1.0
    
    // Purple Slime, Electric Coil & Comet Dust
    var speedMofidier: CGFloat = 0.5
    var effectDuration: TimeInterval = 2.0
    
    init(type: TrapType) {
        self.type = type
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
