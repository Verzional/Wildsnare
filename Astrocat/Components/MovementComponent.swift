//
//  MovementComponent.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 30/04/26.
//

import GameplayKit

class MovementComponent: GKComponent {
    static let defaultSpeed: CGFloat = 300.0
    static let defaultImpulse: CGFloat = 100.0
    
    var speed: CGFloat = defaultSpeed
    var impulse: CGFloat = defaultImpulse
}
