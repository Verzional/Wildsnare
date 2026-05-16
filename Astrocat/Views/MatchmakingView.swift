//
//  MatchmakingView.swift
//  Astrocat
//
//  Created by Arya on 13/05/26.
//

import SwiftUI

struct MatchmakingView: View {
    @EnvironmentObject var matchSystem: MatchSystem
    
    var body: some View {
        VStack {
            Button("Quick Match") {
                matchSystem.startMatch(mode: .quickMatch(playerCount: 2))
            }
            Button("Invite Friend") {
                matchSystem.startMatch(mode: .inviteFriend(playerCount: 2))
            }
        }
    }
}

