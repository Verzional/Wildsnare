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
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.isPlayerInputEnabled = false
        
        let time = scene.gameState?.raceTime ?? 0
        let resultLabel = ResultLabelNode()
        resultLabel.setFinishTime(time)
        scene.mainCameraNode.addChild(resultLabel)
    }
}
