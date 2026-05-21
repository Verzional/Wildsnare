//
//  JumpingState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 02/05/26.
//

import GameplayKit
import SpriteKit

class JumpingState: GKState {
    unowned let locomotionComponent: LocomotionComponent

    init(component: LocomotionComponent) {
        self.locomotionComponent = component
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == IdleState.self || stateClass == RunningState.self
    }

    override func didEnter(from previousState: GKState?) {
        guard let entity = locomotionComponent.entity,
              let nodeComponent = entity.component(ofType: GKSKNodeComponent.self),
              let sprite = nodeComponent.node as? SKSpriteNode else {
            return
        }
        
        guard locomotionComponent.canPlayLocomotionAnimation else { return }
        
        let jumpAnimation = SKAction.playerAnimation(skinPrefix: locomotionComponent.skinPrefix, animation: .jump)
        
        sprite.run(jumpAnimation, withKey: "playerAnimation")
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let entity = locomotionComponent.entity,
              let node = entity.component(ofType: GKSKNodeComponent.self)?.node
        else { return }

        if abs(node.physicsBody?.velocity.dy ?? 0) < 0.1 {
            stateMachine?.enter(IdleState.self)
        }
    }
}
