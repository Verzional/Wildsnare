//
//  GameOverState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 02/05/26.
//

import GameplayKit
import SpriteKit

class GameOverState: GKState {
    unowned let scene: GameScene
    
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
        
        // Multiplayer
        if let matchSystem = scene.matchSystem {
            matchSystem.localPlayerFinished(time: time)
        } else {
            let resultLabel = ResultLabelNode()
            resultLabel.setFinishTime(time)
            scene.mainCameraNode.addChild(resultLabel)
        }
    }
}
