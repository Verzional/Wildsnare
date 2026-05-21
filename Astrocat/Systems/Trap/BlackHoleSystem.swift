//
//  BlackHoleSystem.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit
import SpriteKit

class BlackHoleSystem: GKComponent {
    private var audioNode: SKAudioNode?
    
    override func didAddToEntity() {
        super.didAddToEntity()
        
        if let url = Bundle.main.url(forResource: "BlackHole", withExtension: "wav"),
           let trapNode = entity?.component(ofType: GKSKNodeComponent.self)?.node {
            let sound = SKAudioNode(url: url)
            sound.name = "blackHoleSound"
            sound.autoplayLooped = true
            sound.run(SKAction.changeVolume(to: 0.0, duration: 0))
            audioNode = sound
            
            trapNode.addChild(sound)
            sound.run(SKAction.play())
        }
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let trapData = entity?.component(ofType: TrapComponent.self),
              trapData.type == .blackHole,
              !trapData.isOnCooldown
        else {
            audioNode?.run(SKAction.changeVolume(to: 0.0, duration: 0.2))
            return 
        }
        
        guard let trapNode = entity?.component(ofType: GKSKNodeComponent.self)?.node,
              let scene = trapNode.scene as? GameScene,
              let playerNode = scene.player?.component(ofType: GKSKNodeComponent.self)?.node
        else { return }
        
        let dx = trapNode.position.x - playerNode.position.x
        let dy = trapNode.position.y - playerNode.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance < trapData.radius {
            let forceVector = CGVector(dx: (dx / distance) * trapData.pullForce,
                                       dy: (dy / distance) * trapData.pullForce)
            playerNode.physicsBody?.applyForce(forceVector)
            
            let volume = Float(1.0 - (distance / trapData.radius))
            audioNode?.run(SKAction.changeVolume(to: volume, duration: 0.1))
        } else {
            audioNode?.run(SKAction.changeVolume(to: 0.0, duration: 0.2))
        }
    }
}
