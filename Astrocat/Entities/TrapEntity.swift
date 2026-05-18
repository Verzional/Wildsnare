//
//  TrapEntity.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 08/05/26.
//

import GameplayKit
import SpriteKit

enum TrapType {
    case blackHole
    case forceField
    case purpleSlime
    case electricCoil
    case cometDust
}

class TrapEntity: GKEntity {
    let trapType: TrapType
    
    init(node: SKSpriteNode, type: TrapType) {
        self.trapType = type
        
        super.init()
        
        // Visuals
        node.texture?.filteringMode = .nearest
        node.zPosition = 2
        addComponent(GKSKNodeComponent(node: node))
        
        // Component
        addComponent(TrapComponent(type: type))
        
        // Physics
        setupPhysics(for: node, type: type)
        
        // Systems
        switch type {
        case .blackHole:
            addComponent(BlackHoleSystem())
        case .forceField:
            addComponent(ForceFieldSystem())
        case .purpleSlime:
            addComponent(PurpleSlimeSystem())
        case .electricCoil:
            addComponent(ElectricCoilSystem())
        case .cometDust:
            addComponent(CometDustSystem())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics(for node: SKSpriteNode, type: TrapType) {
        switch type {
        case .blackHole:
            node.physicsBody = nil
        case .forceField:
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        case .cometDust:
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width * 0.35)
        case .electricCoil, .purpleSlime:
            if let texture = node.texture {
                node.physicsBody = SKPhysicsBody(texture: texture, size: node.size)
            }
        }
        
        guard let body = node.physicsBody else { return }
        
        body.isDynamic = false
        body.affectedByGravity = false
        body.allowsRotation = false
        body.pinned = false
        
        body.categoryBitMask = PhysicsCategory.trap
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
    }
}
