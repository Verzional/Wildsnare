//
//  StatusComponent.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit

class StatusComponent: GKComponent {
    var stateMachine: GKStateMachine!
    var skinPrefix: String = "N"
    
    override init() {
        super.init()
        
        let states = [
            NormalState(component: self),
            SlowedDownState(component: self),
            StunnedState(component: self),
            ObscuredState(component: self),
            RepelledState(component: self)
        ]
        
        self.stateMachine = GKStateMachine(states: states)
        self.stateMachine.enter(NormalState.self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
