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
    private var matchResultSystem: MatchResultSystem?
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == CountdownState.self ||
            stateClass == GameOverState.self
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
        
        scene.mainCameraNode.children
            .filter { $0 is ResultLabelNode }
            .forEach { $0.removeFromParent() }
        
        if gameState.isLastRound {
            stateMachine?.enter(GameOverState.self)
        } else if scene.matchSystem != nil {
            showMultiplayerRoundResults()
        } else {
            // Solo: advance rounds locally
            gameState.currentRound += 1
            scene.currentRoundConfig = gameState.currentRoundConfig
            scene.pendingWinnerAdvantage = .first
            scene.resetForNextRound()
            stateMachine?.enter(CountdownState.self)
        }
    }
    
    private func showMultiplayerRoundResults() {
        let time = scene.gameState?.raceTime ?? 0
        let currentRound = scene.gameState?.currentRound ?? 1
        let totalRounds = scene.gameState?.totalRounds ?? 3
        
        let resultSystem = MatchResultSystem(scene: scene)
        matchResultSystem = resultSystem
        resultSystem.show(
            localTime: time,
            title: "Round \(currentRound)/\(totalRounds)",
            completedStatus: "Loading next round..."
        ) { [weak self] results in
            self?.storeWinnerAdvantage(from: results)
        }
        
        scene.matchSystem?.localPlayerFinished(time: time)
    }
    
    private func storeWinnerAdvantage(from results: [RaceResult]) {
        let localID = GKLocalPlayer.local.gamePlayerID
        guard let localIndex = results.firstIndex(where: { $0.senderID == localID }) else {
            scene.pendingWinnerAdvantage = .none
            return
        }
        
        scene.pendingWinnerAdvantage = WinnerAdvantageConfig.forRank(
            localIndex + 1,
            playerCount: results.count
        )
    }
}
