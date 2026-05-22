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
    
    /// Update leaderboard with player finish times (supports up to 16 players)
    func updateLeaderboard(times: [(name: String, time: TimeInterval)]) {
        // Remove old rows
        playerRows.forEach { $0.removeFromParent() }
        playerRows.removeAll()
        
        // Scale font and row height based on player count for readability
        let playerCount = times.count
        let fontSize: CGFloat = playerCount > 8 ? 20 : (playerCount > 4 ? 24 : 28)
        let rowHeight: CGFloat = playerCount > 8 ? 34 : (playerCount > 4 ? 40 : 50)
        let strokeWidth: CGFloat = playerCount > 8 ? 1.5 : 2
        
        // Center the leaderboard vertically
        let totalHeight = CGFloat(min(playerCount, 16)) * rowHeight
        let startY: CGFloat = totalHeight / 2 - rowHeight / 2
        
        for (index, entry) in times.prefix(16).enumerated() {
            let row = SKNode()
            row.zPosition = 1
            row.position = CGPoint(x: 0, y: startY - CGFloat(index) * rowHeight)
            
            let rankLabel = OutlinedLabelNode(fontSize: fontSize, strokeWidth: strokeWidth)
            rankLabel.text = "#\(index + 1)"
            rankLabel.position = CGPoint(x: -200, y: 0)
            row.addChild(rankLabel)
            
            let nameLabel = OutlinedLabelNode(fontSize: fontSize, strokeWidth: strokeWidth)
            // Truncate long names to keep layout clean
            let displayName = entry.name.count > 12 ? String(entry.name.prefix(11)) + "…" : entry.name
            nameLabel.text = displayName
            nameLabel.position = CGPoint(x: -50, y: 0)
            row.addChild(nameLabel)
            
            let timeLabel = OutlinedLabelNode(fontSize: fontSize, strokeWidth: strokeWidth)
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
    
    /// Add a single player finish entry live (supports up to 16 players)
    func addPlayerFinish(name: String, time: TimeInterval, rank: Int) {
        guard rank <= 16 else { return }
        
        let totalExpected = playerRows.count + 1
        let fontSize: CGFloat = totalExpected > 8 ? 20 : (totalExpected > 4 ? 24 : 28)
        let rowHeight: CGFloat = totalExpected > 8 ? 34 : (totalExpected > 4 ? 40 : 50)
        let strokeWidth: CGFloat = totalExpected > 8 ? 1.5 : 2
        
        let row = SKNode()
        row.zPosition = 1
        let totalHeight = CGFloat(totalExpected) * rowHeight
        let startY: CGFloat = totalHeight / 2 - rowHeight / 2
        row.position = CGPoint(x: 0, y: startY - CGFloat(rank - 1) * rowHeight)
        
        let rankLabel = OutlinedLabelNode(fontSize: fontSize, strokeWidth: strokeWidth)
        rankLabel.text = "#\(rank)"
        rankLabel.position = CGPoint(x: -200, y: 0)
        row.addChild(rankLabel)
        
        let nameLabel = OutlinedLabelNode(fontSize: fontSize, strokeWidth: strokeWidth)
        let displayName = name.count > 12 ? String(name.prefix(11)) + "…" : name
        nameLabel.text = displayName
        nameLabel.position = CGPoint(x: -50, y: 0)
        row.addChild(nameLabel)
        
        let timeLabel = OutlinedLabelNode(fontSize: fontSize, strokeWidth: strokeWidth)
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
