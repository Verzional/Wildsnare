//
//  GameOverState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 02/05/26.
//

import GameplayKit
import SpriteKit
import GameKit

class GameOverState: GKState {
    unowned let scene: GameScene
    private var overlay: RoundTransitionOverlay?
    private var finishedPlayers: [(name: String, time: TimeInterval)] = []
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.isPlayerInputEnabled = false
        
        let time = scene.gameState?.raceTime ?? 0
        
        if let matchSystem = scene.matchSystem {
            showMultiplayerOverlay(localTime: time)
            matchSystem.localPlayerFinished(time: time)
        } else {
            let resultLabel = ResultLabelNode()
            resultLabel.setFinishTime(time)
            scene.mainCameraNode.addChild(resultLabel)
        }
    }
    
    private func showMultiplayerOverlay(localTime: TimeInterval) {
        let transitionOverlay = RoundTransitionOverlay()
        scene.mainCameraNode.addChild(transitionOverlay)
        self.overlay = transitionOverlay
        
        let currentRound = scene.gameState?.currentRound ?? 1
        let totalRounds = scene.gameState?.totalRounds ?? 3
        let isLastRound = currentRound >= totalRounds
        
        transitionOverlay.setTitle(isLastRound ? "Race Complete" : "Round \(currentRound)/\(totalRounds)")
        
        // Show local player time first
        let localName = GKLocalPlayer.local.alias
        finishedPlayers = [(name: localName, time: localTime)]
        transitionOverlay.updateLeaderboard(times: finishedPlayers)
        
        // Re-sort and rebuild leaderboard as others finish
        scene.matchSystem?.onPlayerFinishedReceived = { [weak self] message in
            guard let self = self, let overlay = self.overlay else { return }
            if let finishTime = message.finishTime {
                let name = message.playerName ?? message.senderID ?? "Player"
                self.finishedPlayers.append((name: name, time: finishTime))
                self.finishedPlayers.sort { $0.time < $1.time }
                overlay.updateLeaderboard(times: self.finishedPlayers)
            }
        }
        
        // Update status when all results are in
        let previousHandler = scene.matchSystem?.onFinalResultsReceived
        scene.matchSystem?.onFinalResultsReceived = { [weak self] results in
            guard let self = self, let overlay = self.overlay else { return }
            let isLast = (self.scene.gameState?.currentRound ?? 1) >= (self.scene.gameState?.totalRounds ?? 3)
            overlay.setStatus(isLast ? "Final Results" : "Loading next round...")
            previousHandler?(results)
        }
    }
}
