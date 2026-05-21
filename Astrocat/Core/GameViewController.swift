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

    private var currentLevel: Int = 1
    private let finalLevel: Int = 3

    override func viewDidLoad() {
        super.viewDidLoad()
        presentLevel()
    }

    private func presentLevel() {
        guard let scene = GKScene(fileNamed: "GameScene"),
              let sceneNode = scene.rootNode as? GameScene,
              let view = self.view as? SKView else { return }

        sceneNode.entities = scene.entities
        sceneNode.graphs = scene.graphs
        sceneNode.scaleMode = .aspectFill
        sceneNode.levelSeed = levelSeed
        sceneNode.matchSystem = matchSystem

        sceneNode.onGameFinished = { [weak self] results in
            guard let self else { return }

            if self.currentLevel < self.finalLevel {
                self.showRoundVictoryOverlay(results: results)
            } else {
                self.showFinalResults(results: results)
            }
        }

        view.presentScene(sceneNode)
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
    }

    private func showRoundVictoryOverlay(results: [RaceResult]) {
        let overlayVC = UIHostingController(
            rootView: RoundVictoryOverlayView(level: currentLevel, results: results) { [weak self] in
                guard let self else { return }
                self.dismiss(animated: true) {
                    self.currentLevel += 1
                    self.levelSeed = UInt64(Date().timeIntervalSince1970)
                    self.presentLevel()
                }
            }
        )
        overlayVC.modalPresentationStyle = .overFullScreen
        overlayVC.view.backgroundColor = .clear
        present(overlayVC, animated: true)
    }

    private func showFinalResults(results: [RaceResult]) {
        let ms = matchSystem
        let resultsVC = UIHostingController(rootView: ResultsView(results: results) {
            ms?.leaveMatch()
            self.presentingViewController?.dismiss(animated: true)
        })
        resultsVC.modalPresentationStyle = .fullScreen
        present(resultsVC, animated: true)
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
