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
    private var matchResultSystem: MatchResultSystem?
    
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
            showMultiplayerResults(localTime: time)
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
    
    private func showMultiplayerResults(localTime: TimeInterval) {
        let resultSystem = MatchResultSystem(scene: scene)
        matchResultSystem = resultSystem
        resultSystem.show(
            localTime: localTime,
            title: "Race Complete",
            completedStatus: "Final Results"
        ) { [weak self] results in
            guard let self else { return }
            self.scene.isPaused = true
            self.scene.onGameFinished?(results)
        }
    }
}
