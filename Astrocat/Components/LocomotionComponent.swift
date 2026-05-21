//
//  StateComponent.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit

class LocomotionComponent: GKComponent {
    var stateMachine: GKStateMachine!
    var skinPrefix: String = "N"
    
    override init() {
        super.init()
        
        let states = [
            IdleState(component: self),
            JumpingState(component: self),
            RunningState(component: self),
        ]
        
        self.stateMachine = GKStateMachine(states: states)
        self.stateMachine.enter(IdleState.self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var canPlayLocomotionAnimation: Bool {
        guard let statusMachine = entity?.component(ofType: StatusComponent.self)?.stateMachine,
              let currentStatus = statusMachine.currentState else {
            return true 
        }
        
        let isStunned = currentStatus is StunnedState
        let isRepelled = currentStatus is RepelledState
        let isSlimed = currentStatus is SlowedDownState
        
        return !(isStunned || isRepelled || isSlimed)
    }
    
    func resumeCurrentStateAnimation() {
        if let currentState = stateMachine.currentState {
            currentState.didEnter(from: nil)
        }
    }
    
    func playIdleAnimation() {
        guard let entity,
              let sprite = entity.component(ofType: GKSKNodeComponent.self)?.node as? SKSpriteNode
        else { return }
        
        sprite.removeAction(forKey: "playerAnimation")
        
        let idleAnimation = SKAction.playerAnimation(
            skinPrefix: skinPrefix,
            animation: .idle
        )
        
        sprite.run(idleAnimation, withKey: "playerAnimation")
    }
}
