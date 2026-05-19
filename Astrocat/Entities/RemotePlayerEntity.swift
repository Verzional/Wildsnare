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
    
    func updatePosition(x: CGFloat, y: CGFloat, dx: CGFloat, dy: CGFloat) {
        node.removeAction(forKey: "remoteMove")
        let move = SKAction.move(to: CGPoint(x: x, y: y), duration: 0.06)
        node.run(move, withKey: "remoteMove")
        
        if dx != 0 {
            node.xScale = dx > 0 ? abs(node.xScale) : -abs(node.xScale)
        }
        
        let tilt: CGFloat = dy > 50 ? -5 : (dy < -50 ? 5 : 0)
        node.removeAction(forKey: "remoteTilt")
        let rotate = SKAction.rotate(toAngle: tilt * (.pi / 180), duration: 0.06)
        node.run(rotate, withKey: "remoteTilt")
    }
    
    func removeFromScene() {
        node.removeFromParent()
    }
    
}
