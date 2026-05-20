//
//  OutlinedLabelNode.swift
//  Astrocat
//
//  Created by Andrew Wallace on 20/05/26.
//

import SpriteKit

class OutlinedLabelNode: SKNode {
    private var outlineLabels: [SKLabelNode] = []
    private let fillLabel: SKLabelNode
    
    var text: String? {
        didSet {
            outlineLabels.forEach { $0.text = text }
            fillLabel.text = text
        }
    }
    
    init(
        fontName: String = "UpheavalTT-BRK-",
        fontSize: CGFloat = 80,
        strokeWidth: CGFloat = 5,
        fillColor: SKColor = SKColor(
            red: 255.0 / 255.0,
            green: 194.0 / 255.0,
            blue: 14.0 / 255.0,
            alpha: 1.0
        ),
        outlineColor: SKColor = SKColor(
            red: 0.0 / 255.0,
            green: 16.0 / 255.0,
            blue: 75.0 / 255.0,
            alpha: 1.0
        )
    ) {
        fillLabel = SKLabelNode(fontNamed: fontName)
        super.init()
        
        let offsets: [CGPoint] = [
            CGPoint(x: -strokeWidth, y: 0),
            CGPoint(x: strokeWidth, y: 0),
            CGPoint(x: 0, y: strokeWidth),
            CGPoint(x: 0, y: -strokeWidth),
            CGPoint(x: -strokeWidth, y: -strokeWidth),
            CGPoint(x: strokeWidth, y: -strokeWidth)
        ]
        
        for offset in offsets {
            let label = SKLabelNode(fontNamed: fontName)
            label.fontSize = fontSize
            label.fontColor = outlineColor
            label.position = offset
            label.zPosition = 0
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            addChild(label)
            outlineLabels.append(label)
        }
        
        fillLabel.fontSize = fontSize
        fillLabel.fontColor = fillColor
        fillLabel.position = .zero
        fillLabel.zPosition = 1
        fillLabel.horizontalAlignmentMode = .center
        fillLabel.verticalAlignmentMode = .center
        addChild(fillLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
