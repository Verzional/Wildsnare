import SpriteKit
import GameplayKit

class RemotePlayerEntity: GKEntity {
    let node: SKSpriteNode
    private let nameLabel: OutlinedLabelNode
    private let skinPrefix: String
    private var currentAnimationKey: String = ""
    
    init(scene: SKScene, colorVariant: CatColorVariant, displayName: String, skinPrefix: String = "N") {
        self.skinPrefix = skinPrefix
        
        let idleAtlas = SKTextureAtlas(named: "\(skinPrefix)-Idle")
        let firstFrame = idleAtlas.textureNamed("\(skinPrefix)I-Frame-1")
        
        node = SKSpriteNode(texture: firstFrame)
        node.setScale(1.0)
        node.zPosition = 1
        node.texture?.filteringMode = .nearest
        node.shader = colorVariant.makeShader()
        
        nameLabel = OutlinedLabelNode(
            fontName: "UpheavalTT-BRK-",
            fontSize: 14,
            strokeWidth: 1.5,
            fillColor: .white,
            outlineColor: SKColor(red: 0, green: 16.0/255.0, blue: 75.0/255.0, alpha: 1.0)
        )
        nameLabel.position = CGPoint(x: 0, y: 44)
        nameLabel.zPosition = 2
        nameLabel.text = displayName
        
        super.init()
        node.addChild(nameLabel)
        scene.addChild(node)
        
        playAnimation(.idle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePosition(x: CGFloat, y: CGFloat, dx: CGFloat, dy: CGFloat) {
        node.removeAction(forKey: "remoteMove")
        node.run(SKAction.move(to: CGPoint(x: x, y: y), duration: 0.1), withKey: "remoteMove")
        
        if dx != 0 {
            node.xScale = dx > 0 ? abs(node.xScale) : -abs(node.xScale)
            nameLabel.xScale = dx > 0 ? 1 : -1
        }
        
        let isAirborne = dy > 50 || dy < -50
        let isMoving = abs(dx) > 10
        
        if isAirborne {
            playAnimation(.jump)
        } else if isMoving {
            playAnimation(.run)
        } else {
            playAnimation(.idle)
        }
    }
    
    private func playAnimation(_ animation: PlayerAnimation) {
        let key = animation.atlasName
        guard currentAnimationKey != key else { return }
        currentAnimationKey = key
        let action = SKAction.playerAnimation(skinPrefix: skinPrefix, animation: animation)
        node.run(action, withKey: "playerAnimation")
    }
    
    func removeFromScene() {
        node.removeFromParent()
    }
}
