//
//  RoundOverState.swift
//  Astrocat
//
//  Created by Andrew Wallace on 19/05/26.
//

import GameplayKit
import SpriteKit
import GameKit

class RoundOverState: GKState {
    unowned let scene: GameScene
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == CountdownState.self || stateClass == GameOverState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.isPlayerInputEnabled = false
        
        let time = scene.gameState?.raceTime ?? 0
        let resultLabel = ResultLabelNode()
        resultLabel.setFinishTime(time)
        scene.mainCameraNode.addChild(resultLabel)
        
        let waitAction = SKAction.wait(forDuration: 3.0)
        let advanceAction = SKAction.run {
            [weak self] in
            self?.advanceToNextRoundOrEnd()
        }
        scene.run(SKAction.sequence([waitAction, advanceAction]))
    }
    
    private func advanceToNextRoundOrEnd() {
        guard let gameState = scene.gameState else { return }
        
        // Remove result UI
        scene.mainCameraNode.children
            .filter { $0 is ResultLabelNode }
            .forEach { $0.removeFromParent() }
        
        if gameState.isLastRound {
            stateMachine?.enter(GameOverState.self)
        } else {
            let rank = determineLocalPlayerRank()
            let playerCount: Int
            
            if scene.matchSystem != nil {
                playerCount = scene.matchSystem?.match?.players.count ?? 0
            } else {
                playerCount = 1
            }
            
            let advantage = WinnerAdvantageConfig.forRank(rank, playerCount: playerCount)
            
            // Next round
            gameState.currentRound += 1
            scene.currentRoundConfig = gameState.currentRoundConfig
            scene.resetForNextRound()
            scene.applyWinnerAdvantage(advantage)
            stateMachine?.enter(CountdownState.self)
        }
    }
    
    private func determineLocalPlayerRank() -> Int {
        let localTime = scene.gameState?.raceTime ?? 0
        
        // Solo
        guard let matchSystem = scene.matchSystem else { return 1 }
        
        // Multiplayer
        let fasterCount = matchSystem.playerTimes.values.filter { $0 < localTime }.count
        return fasterCount + 1
    }
}
