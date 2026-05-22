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
                    guard let self = self else { return }
                    let ms = self.matchSystem
                    // Capture presentingVC reference before presenting results
                    // (weak self may be nil by the time user taps dismiss)
                    weak var presenter = self.presentingViewController
                    let resultsVC = UIHostingController(rootView: MatchVictoryScreen(results: results) {
                        ms?.leaveMatch()
                        // Dismiss the entire presentation stack (resultsVC + GameViewController)
                        presenter?.dismiss(animated: true) {
                            AudioManager.shared.playBGM(.home)
                        }
                    })
                    resultsVC.modalPresentationStyle = .fullScreen
                    self.present(resultsVC, animated: true)
                }
                
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    view.ignoresSiblingOrder = true
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Clean up the SKView scene to release GameScene resources
        if isBeingDismissed || parent == nil {
            if let skView = self.view as? SKView {
                skView.presentScene(nil)
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
