//
//  IdleState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 02/05/26.
//

import GameplayKit
import SpriteKit

class IdleState: GKState {
    unowned let locomotionComponent: LocomotionComponent
    
    init(component: LocomotionComponent) {
        self.locomotionComponent = component
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == JumpingState.self || stateClass == RunningState.self
    }
    
    override func didEnter(from previousState: GKState?) {        
        guard let entity = locomotionComponent.entity,
              let nodeComponent = entity.component(ofType: GKSKNodeComponent.self),
              let sprite = nodeComponent.node as? SKSpriteNode else {
            return
        }
        
        guard locomotionComponent.canPlayLocomotionAnimation else { return }
        
        let idleAnimation = SKAction.playerAnimation(skinPrefix: locomotionComponent.skinPrefix, animation: .idle)
        
        sprite.run(idleAnimation, withKey: "playerAnimation")
    }
}
