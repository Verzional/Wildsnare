//
//  RemotePlayerEntity.swift
//  Astrocat
//
//  Created by Arya on 18/05/26.
//

import SpriteKit
import GameplayKit

class RemotePlayerEntity: GKEntity {
    let node: SKSpriteNode
    
    init(scene: SKScene) {
        node = SKSpriteNode(imageNamed: "Player")
        node.setScale(1.0)
        node.zPosition = 1
        
        node.color = .cyan
        node.colorBlendFactor = 0.4
        super.init()
        scene.addChild(node)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePosition(x: CGFloat, y: CGFloat, dx: CGFloat) {
        let move = SKAction.move(to: CGPoint(x: x, y: y), duration: 0.1)
        node.run(move, withKey: "remoteMove")
        
        if dx != 0 {
            node.xScale = dx > 0 ? abs(node.xScale) : -abs(node.xScale)
        }
    }
    
    func removeFromScene() {
        node.removeFromParent()
    }
    
}
