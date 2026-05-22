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
    
    private var loadingOverlay: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show loading overlay immediately
        showLoadingOverlay()
        
        if let scene = GKScene(fileNamed: "GameScene") {
            if let sceneNode = scene.rootNode as! GameScene? {
                
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                sceneNode.scaleMode = .aspectFill
                sceneNode.levelSeed = levelSeed
                sceneNode.matchSystem = matchSystem
                
                sceneNode.onSceneReady = { [weak self] in
                    self?.hideLoadingOverlay()
                }
                
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
    
    // MARK: - Loading Overlay
    
    private func showLoadingOverlay() {
        let overlay = UIView(frame: view.bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.backgroundColor = UIColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0)
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        // Cat image
        let catImage = UIImageView(image: UIImage(named: "CatAstronaut"))
        catImage.contentMode = .scaleAspectFit
        catImage.translatesAutoresizingMaskIntoConstraints = false
        catImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        catImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        // Floating animation
        UIView.animate(withDuration: 1.5, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            catImage.transform = CGAffineTransform(translationX: 0, y: -12)
        }
        
        // Loading label
        let label = UILabel()
        label.text = "LOADING..."
        label.font = UIFont(name: "UpheavalTT-BRK-", size: 28)
        label.textColor = UIColor(red: 1.0, green: 0.80, blue: 0.06, alpha: 1.0)
        label.textAlignment = .center
        
        stack.addArrangedSubview(catImage)
        stack.addArrangedSubview(label)
        overlay.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])
        
        view.addSubview(overlay)
        self.loadingOverlay = overlay
    }
    
    private func hideLoadingOverlay() {
        guard let overlay = loadingOverlay else { return }
        UIView.animate(withDuration: 0.4, animations: {
            overlay.alpha = 0
        }) { _ in
            overlay.removeFromSuperview()
        }
        self.loadingOverlay = nil
    }
    
    // MARK: - Lifecycle
    
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
