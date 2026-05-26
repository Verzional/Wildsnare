//
//  PlayingState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 02/05/26.
//

import GameplayKit
import SpriteKit

class PlayingState: GKState {
    unowned let scene: GameScene
    
    private let maxRoundTime: TimeInterval = 150.0
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == RoundOverState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.isPlayerInputEnabled = true
        scene.gameState?.raceTime = 0
        scene.applyPendingWinnerAdvantage()
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let gameState = scene.gameState else { return }
        gameState.raceTime += seconds
        scene.timerLabel.updateTime(gameState.raceTime)
        
        // Force-finish if time limit exceeded
        if gameState.raceTime >= maxRoundTime {
            stateMachine?.enter(RoundOverState.self)
        }
    }
}
