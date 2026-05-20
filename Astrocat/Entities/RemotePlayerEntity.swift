import SpriteKit
import GameplayKit

class RemotePlayerEntity: GKEntity {
    let node: SKSpriteNode
    private let nameLabel: SKLabelNode
    
        // Cache animations so atlases are only loaded once
    private lazy var idleAnimation: SKAction = {
        SKAction.buildAnimation(atlasName: "N-Idle", prefix: "NI")
    }()
    private lazy var runAnimation: SKAction = {
        SKAction.buildAnimation(atlasName: "N-Run", prefix: "NR")
    }()
    private lazy var jumpAnimation: SKAction = {
        SKAction.buildAnimation(atlasName: "N-Jump", prefix: "NJ")
    }()
    
        // Track current state to avoid restarting the same animation every frame
    private var currentAnimationKey: String = ""
    
    init(scene: SKScene, colorVariant: CatColorVariant, displayName: String) {
            // Use first idle frame as initial texture — avoids blank sprite on spawn
        let idleAtlas = SKTextureAtlas(named: "N-Idle")
        let firstFrame = idleAtlas.textureNamed("NI-Frame-1")
        
        node = SKSpriteNode(texture: firstFrame)
        node.setScale(1.0)
        node.zPosition = 1
        node.texture?.filteringMode = .nearest
        node.shader = colorVariant.makeShader()
        
        nameLabel = SKLabelNode(text: displayName)
        nameLabel.fontName = "UpheavalTT-BRK-"
        nameLabel.fontSize = 14
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: 44)
        nameLabel.zPosition = 2
        nameLabel.horizontalAlignmentMode = .center
        
        super.init()
        node.addChild(nameLabel)
        scene.addChild(node)
        
            // Start with idle
        playAnimation(idleAnimation, key: "idle")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePosition(x: CGFloat, y: CGFloat, dx: CGFloat, dy: CGFloat) {
            // Movement interpolation
        node.removeAction(forKey: "remoteMove")
        node.run(SKAction.move(to: CGPoint(x: x, y: y), duration: 0.1), withKey: "remoteMove")
        
            // Facing direction
        if dx != 0 {
            node.xScale = dx > 0 ? abs(node.xScale) : -abs(node.xScale)
            nameLabel.xScale = dx > 0 ? 1 : -1
        }
        
            // Animation state — inferred from velocity
        let isAirborne = dy > 50 || dy < -50
        let isMoving = abs(dx) > 10
        
        if isAirborne {
            playAnimation(jumpAnimation, key: "jump")
        } else if isMoving {
            playAnimation(runAnimation, key: "run")
        } else {
            playAnimation(idleAnimation, key: "idle")
        }
    }
    
    private func playAnimation(_ animation: SKAction, key: String) {
        guard currentAnimationKey != key else { return }  // don't restart same anim
        currentAnimationKey = key
        node.run(animation, withKey: "playerAnimation")
    }
    
    func removeFromScene() {
        node.removeFromParent()
    }
}
