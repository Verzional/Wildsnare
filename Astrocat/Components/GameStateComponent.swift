//
//  GameStateComponent.swift
//  Astrocat
//
//  Created by Andrew Wallace on 19/05/26.
//

import GameplayKit

class GameStateComponent {
    let stateMachine: GKStateMachine
    var raceTime: TimeInterval = 0
    var currentRound: Int = 1
    var totalRounds: Int = 3
    
    var currentRoundConfig: RoundConfig {
        let index = min(currentRound - 1, RoundConfig.allRounds.count - 1)
        return RoundConfig.allRounds[index]
    }
    
    var isLastRound: Bool {
        currentRound >= totalRounds
    }
    
    init(scene: GameScene) {
        let states: [GKState] = [
            CountdownState(scene: scene),
            PlayingState(scene: scene),
            RoundOverState(scene: scene),
            GameOverState(scene: scene)
        ]
        self.stateMachine = GKStateMachine(states: states)
    }
}
