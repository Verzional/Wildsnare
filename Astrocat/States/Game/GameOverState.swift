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
        print("[GameOverState] didEnter: round=\(scene.gameState?.currentRound ?? -1), time=\(time), isMultiplayer=\(scene.matchSystem != nil)")
        
        if let matchSystem = scene.matchSystem {
            showMultiplayerOverlay(localTime: time)
            matchSystem.localPlayerFinished(time: time)
        } else {
            // Solo Mode
            let localID = GKLocalPlayer.local.gamePlayerID
            let localName = GKLocalPlayer.local.alias
            let results = [RaceResult(senderID: localID, playerName: localName, finishTime: time)]
            self.scene.isPaused = true
            self.scene.onGameFinished?(results)
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
        
        // Build initial leaderboard from all known finish times (includes players who finished before us)
        let localID = GKLocalPlayer.local.gamePlayerID
        let localName = GKLocalPlayer.local.alias
        finishedPlayers = [(name: localName, time: localTime)]
        
        if let playerTimes = scene.matchSystem?.playerTimes {
            for (id, time) in playerTimes where id != localID {
                let name = scene.matchSystem?.match?.players.first(where: { $0.gamePlayerID == id })?.alias ?? "Player"
                finishedPlayers.append((name: name, time: time))
            }
        }
        finishedPlayers.sort { $0.time < $1.time }
        transitionOverlay.updateLeaderboard(times: finishedPlayers)
        
        // Add new players as they finish
        scene.matchSystem?.onPlayerFinishedReceived = { [weak self] message in
            guard let self = self, let overlay = self.overlay else { return }
            if let finishTime = message.finishTime, let id = message.senderID {
                let fallbackName = "Player"
                var name = message.playerName?.isEmpty == false ? message.playerName! : fallbackName
                if name == fallbackName, let p = self.scene.matchSystem?.match?.players.first(where: { $0.gamePlayerID == id }) {
                    name = p.alias
                }
                
                // Avoid duplicates
                if !self.finishedPlayers.contains(where: { $0.time == finishTime && $0.name == name }) {
                    self.finishedPlayers.append((name: name, time: finishTime))
                    self.finishedPlayers.sort { $0.time < $1.time }
                    overlay.updateLeaderboard(times: self.finishedPlayers)
                }
            }
        }
        
        // Update status when all results are in
        scene.matchSystem?.onFinalResultsReceived = { [weak self] results in
            guard let self = self, let overlay = self.overlay else {
                print("[GameOverState] onFinalResultsReceived: self or overlay is nil")
                return
            }
            let currentRound = self.scene.gameState?.currentRound ?? 1
            let totalRounds = self.scene.gameState?.totalRounds ?? 3
            let isLast = currentRound >= totalRounds
            print("[GameOverState] onFinalResultsReceived: round=\(currentRound)/\(totalRounds), isLast=\(isLast)")
            overlay.setStatus(isLast ? "Final Results" : "Loading next round...")
            
            // Only show ResultsView on the final round
            if isLast {
                self.scene.isPaused = true
                self.scene.onGameFinished?(results)
            }
        }
    }
}
