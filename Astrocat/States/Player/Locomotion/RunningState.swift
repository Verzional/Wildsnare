//
//  RunningState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 18/05/26.
//

import GameplayKit
import SpriteKit

class RunningState: GKState {
    unowned let locomotionComponent: LocomotionComponent
    
    init(component: LocomotionComponent) {
        self.locomotionComponent = component
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == JumpingState.self || stateClass == IdleState.self
    }
    
    override func didEnter(from previousState: GKState?) {        
        guard let entity = locomotionComponent.entity,
              let nodeComponent = entity.component(ofType: GKSKNodeComponent.self),
              let sprite = nodeComponent.node as? SKSpriteNode else {
            return
        }
        
        guard locomotionComponent.canPlayLocomotionAnimation else { return }
        
        let runAnimation = SKAction.playerAnimation(skinPrefix: locomotionComponent.skinPrefix, animation: .run)
        
        sprite.run(runAnimation, withKey: "playerAnimation")
        
        if let url = Bundle.main.url(forResource: "Run", withExtension: "mp3") {
            let sound = SKAudioNode(url: url)
            sound.name = "locomotionSound"
            sound.autoplayLooped = false
            sprite.addChild(sound)
            sound.run(SKAction.play())
        }
    }
    
    override func willExit(to nextState: GKState) {
        locomotionComponent.entity?.component(ofType: GKSKNodeComponent.self)?.node.childNode(withName: "locomotionSound")?.removeFromParent()
    }
}
