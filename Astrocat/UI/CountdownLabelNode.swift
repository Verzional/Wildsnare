//
//  CountdownLabelNode.swift
//  Astrocat
//
//  Created by Andrew Wallace on 20/05/26.
//

import SpriteKit

class CountdownLabelNode: OutlinedLabelNode {
    init() {
        super.init(fontSize: 80, strokeWidth: 3)
        zPosition = 200
        position = .zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
