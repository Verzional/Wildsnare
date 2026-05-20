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
    private let nameLabel: SKLabelNode 
    
    init(scene: SKScene, colorVariant: CatColorVariant, displayName: String) {
        node = SKSpriteNode(imageNamed: "//Player")
        node.setScale(1.0)
        node.zPosition = 1
        node.texture?.filteringMode = .nearest
        node.shader = colorVariant.makeShader()
        
        nameLabel = SKLabelNode(text: displayName)
        nameLabel.fontName = "UpheavalTT-BRK-"
        nameLabel.fontSize = 14
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: 44)
        nameLabel.zPosition = 2
        nameLabel.horizontalAlignmentMode = .center
        
        super.init()
        node.addChild(nameLabel)
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
            nameLabel.xScale = dx > 0 ? 1 : -1
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
