//
//  CountdownState.swift
//  Astrocat
//
//  Created by Andrew Wallace on 19/05/26.
//

import GameplayKit
import SpriteKit

class CountdownState: GKState {
    unowned let scene: GameScene
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == PlayingState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.isPlayerInputEnabled = false
        scene.timerLabel.reset()
        
        if let currentRound = scene.gameState?.currentRound {
            switch currentRound {
            case 1:
                AudioManager.shared.playBGM(.earth)
            case 2:
                AudioManager.shared.playBGM(.sky)
            case 3:
                AudioManager.shared.playBGM(.space)
            default:
                break
            }
        }
        
        let countdownLabel = CountdownLabelNode()
        scene.mainCameraNode.addChild(countdownLabel)
        
        let countdown = SKAction.sequence([
            SKAction.run { countdownLabel.text = "3" },
            SKAction.wait(forDuration: 1.0),
            SKAction.run { countdownLabel.text = "2" },
            SKAction.wait(forDuration: 1.0),
            SKAction.run { countdownLabel.text = "1" },
            SKAction.wait(forDuration: 1.0),
            SKAction.run { countdownLabel.text = "GO!" },
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in
                countdownLabel.removeFromParent()
                self?.stateMachine?.enter(PlayingState.self)
            }
        ])
        
        countdownLabel.run(countdown)
    }
}
