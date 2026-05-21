//
//  SlowedDownState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 12/05/26.
//

import GameplayKit
import SpriteKit

class SlowedDownState: GKState {
    unowned let statusComp: StatusComponent
    var elapsed: TimeInterval = 0
    var duration: TimeInterval = 0
    var modifier: CGFloat = 0.5
    
    init(component: StatusComponent) {
        self.statusComp = component
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        elapsed = 0
        
        guard let entity = statusComp.entity,
              let nodeComponent = entity.component(ofType: GKSKNodeComponent.self),
              let sprite = nodeComponent.node as? SKSpriteNode else {
            return
        }
        
        let slimedAnimation = SKAction.playerAnimation(skinPrefix: statusComp.skinPrefix, animation: .slimed)
        
        sprite.run(slimedAnimation, withKey: "playerAnimation")
        
        let url = Bundle.main.url(forResource: "Slime", withExtension: "wav")
        if let url = url {
            let sound = SKAudioNode(url: url)
            sound.name = "statusSound"
            sound.autoplayLooped = false
            sprite.addChild(sound)
            sound.run(SKAction.play())
        }
    }
    
    override func willExit(to nextState: GKState) {
        statusComp.entity?.component(ofType: GKSKNodeComponent.self)?.node.childNode(withName: "statusSound")?.removeFromParent()
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsed += seconds
        
        if elapsed >= duration {
            self.stateMachine?.enter(NormalState.self)
        }
    }
    
    func reset() {
        self.elapsed = 0
    }
}
