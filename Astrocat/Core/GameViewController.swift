//
//  GameViewController.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 30/04/26.
//

import UIKit
import SwiftUI
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var levelSeed: UInt64?
    
    
    var matchSystem: MatchSystem?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GKScene(fileNamed: "GameScene") {
            if let sceneNode = scene.rootNode as! GameScene? {
                
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                sceneNode.scaleMode = .aspectFill
                sceneNode.levelSeed = levelSeed
                sceneNode.matchSystem = matchSystem
                
                sceneNode.onGameFinished = { [weak self] results in
                    let ms = self?.matchSystem
                    let resultsVC = UIHostingController(rootView:
                                                            ResultsView(results: results) {
                        ms?.leaveMatch()
                        self?.presentingViewController?.dismiss(animated: true)
                    }
                    )
                    resultsVC.modalPresentationStyle = .fullScreen
                    self?.present(resultsVC, animated: true)
                }
                sceneNode.levelSeed = levelSeed
                sceneNode.matchSystem = matchSystem
                
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    view.ignoresSiblingOrder = true
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    override func loadView() {
        let skView = SKView()
        skView.isMultipleTouchEnabled = true
        self.view = skView
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
