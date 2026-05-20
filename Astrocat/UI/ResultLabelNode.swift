//
//  ResultLabelNode.swift
//  Astrocat
//
//  Created by Andrew Wallace on 20/05/26.
//

import SpriteKit

class ResultLabelNode: SKLabelNode {
    override init() {
        super.init()
        
        fontName = "Menlo-Bold"
        fontSize = 40
        fontColor = .black
        zPosition = 200
        position = CGPoint(x: 0, y: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setFinishTime(_ time: TimeInterval) {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let hundredths = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        
        let resultLabel = ResultLabelNode()
        text = String(format: "Finish! %d:%02d.%02d", minutes, seconds, hundredths)
    }
}
