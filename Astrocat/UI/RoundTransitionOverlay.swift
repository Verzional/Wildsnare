//
//  RoundTransitionOverlay.swift
//  Astrocat
//

import SpriteKit

class RoundTransitionOverlay: SKNode {
    private let background: SKSpriteNode
    private let titleLabel: OutlinedLabelNode
    private let statusLabel: OutlinedLabelNode
    private var playerRows: [SKNode] = []
    
    override init() {
        background = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.7), size: CGSize(width: 800, height: 1200))
        background.zPosition = 0
        
        titleLabel = OutlinedLabelNode(fontSize: 48, strokeWidth: 3)
        titleLabel.position = CGPoint(x: 0, y: 200)
        titleLabel.zPosition = 1
        
        statusLabel = OutlinedLabelNode(fontSize: 28, strokeWidth: 2)
        statusLabel.position = CGPoint(x: 0, y: -250)
        statusLabel.zPosition = 1
        
        super.init()
        
        zPosition = 300
        addChild(background)
        addChild(titleLabel)
        addChild(statusLabel)
        
        titleLabel.text = "Round Complete"
        statusLabel.text = "Waiting for others..."
        
        // Pulse animation on status label
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.8),
            SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        ])
        statusLabel.run(SKAction.repeatForever(pulse))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    func setStatus(_ text: String) {
        statusLabel.removeAllActions()
        statusLabel.alpha = 1.0
        statusLabel.text = text
    }
    
    /// Update leaderboard with player finish times
    func updateLeaderboard(times: [(name: String, time: TimeInterval)]) {
        // Remove old rows
        playerRows.forEach { $0.removeFromParent() }
        playerRows.removeAll()
        
        let startY: CGFloat = 120
        let rowHeight: CGFloat = 50
        
        for (index, entry) in times.prefix(4).enumerated() {
            let row = SKNode()
            row.zPosition = 1
            row.position = CGPoint(x: 0, y: startY - CGFloat(index) * rowHeight)
            
            let rankLabel = OutlinedLabelNode(fontSize: 28, strokeWidth: 2)
            rankLabel.text = "#\(index + 1)"
            rankLabel.position = CGPoint(x: -200, y: 0)
            row.addChild(rankLabel)
            
            let nameLabel = OutlinedLabelNode(fontSize: 28, strokeWidth: 2)
            nameLabel.text = entry.name
            nameLabel.position = CGPoint(x: -50, y: 0)
            row.addChild(nameLabel)
            
            let timeLabel = OutlinedLabelNode(fontSize: 28, strokeWidth: 2)
            let minutes = Int(entry.time) / 60
            let seconds = Int(entry.time) % 60
            let hundredths = Int((entry.time.truncatingRemainder(dividingBy: 1)) * 100)
            timeLabel.text = String(format: "%d:%02d.%02d", minutes, seconds, hundredths)
            timeLabel.position = CGPoint(x: 150, y: 0)
            row.addChild(timeLabel)
            
            addChild(row)
            playerRows.append(row)
        }
    }
    
    /// Add a single player finish entry live
    func addPlayerFinish(name: String, time: TimeInterval, rank: Int) {
        let row = SKNode()
        row.zPosition = 1
        let startY: CGFloat = 120
        let rowHeight: CGFloat = 50
        row.position = CGPoint(x: 0, y: startY - CGFloat(rank - 1) * rowHeight)
        
        let rankLabel = OutlinedLabelNode(fontSize: 28, strokeWidth: 2)
        rankLabel.text = "#\(rank)"
        rankLabel.position = CGPoint(x: -200, y: 0)
        row.addChild(rankLabel)
        
        let nameLabel = OutlinedLabelNode(fontSize: 28, strokeWidth: 2)
        nameLabel.text = name
        nameLabel.position = CGPoint(x: -50, y: 0)
        row.addChild(nameLabel)
        
        let timeLabel = OutlinedLabelNode(fontSize: 28, strokeWidth: 2)
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let hundredths = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        timeLabel.text = String(format: "%d:%02d.%02d", minutes, seconds, hundredths)
        timeLabel.position = CGPoint(x: 150, y: 0)
        row.addChild(timeLabel)
        
        addChild(row)
        playerRows.append(row)
        
        // Pop-in animation
        row.setScale(0)
        row.run(SKAction.scale(to: 1.0, duration: 0.2))
    }
}
