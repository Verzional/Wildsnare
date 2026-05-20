//
//  RoundOverState.swift
//  Astrocat
//
//  Created by Andrew Wallace on 19/05/26.
//

import GameplayKit
import SpriteKit

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
        
        // Solo or last round in Multiplayer
        if gameState.isLastRound || scene.matchSystem != nil {
            stateMachine?.enter(GameOverState.self)
        } else {
            // Next round
            gameState.currentRound += 1
            scene.resetForNextRound()
            stateMachine?.enter(CountdownState.self)
        }
    }
}
