//
//  MatchResultSystem.swift
//  Astrocat
//

import GameKit

class MatchResultSystem {
    unowned let scene: GameScene
    private var overlay: RoundTransitionOverlay?
    private var finishedPlayersByID: [String: (name: String, time: TimeInterval)] = [:]
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    func show(
        localTime: TimeInterval,
        title: String,
        completedStatus: String,
        onComplete: (([RaceResult]) -> Void)? = nil
    ) {
        let transitionOverlay = RoundTransitionOverlay()
        scene.mainCameraNode.addChild(transitionOverlay)
        overlay = transitionOverlay
        
        transitionOverlay.setTitle(title)
        seedLeaderboard(localTime: localTime)
        updateOverlayLeaderboard()
        
        scene.matchSystem?.onPlayerFinishedReceived = { [weak self] message in
            self?.appendFinishedPlayer(from: message)
        }
        
        scene.matchSystem?.onFinalResultsReceived = { [weak self] results in
            guard let self, let overlay = self.overlay else { return }
            overlay.setStatus(completedStatus)
            onComplete?(results)
        }
    }
    
    private func seedLeaderboard(localTime: TimeInterval) {
        let localID = GKLocalPlayer.local.gamePlayerID
        let localName = GKLocalPlayer.local.alias
        finishedPlayersByID = [
            localID: (name: localName, time: localTime)
        ]
        
        if let playerTimes = scene.matchSystem?.playerTimes {
            for (id, time) in playerTimes where id != localID {
                let name = playerName(for: id, fallback: "Player")
                finishedPlayersByID[id] = (name: name, time: time)
            }
        }
    }
    
    private func appendFinishedPlayer(from message: GameMessage) {
        guard overlay != nil, let finishTime = message.finishTime, let id = message.senderID else { return }
        
        let fallbackName = "Player"
        let messageName = message.playerName?.isEmpty == false ? message.playerName! : fallbackName
        let name = messageName == fallbackName ? playerName(for: id, fallback: fallbackName) : messageName
        
        finishedPlayersByID[id] = (name: name, time: finishTime)
        updateOverlayLeaderboard()
    }
    
    private func updateOverlayLeaderboard() {
        let finishedPlayers = finishedPlayersByID.values.sorted { $0.time < $1.time }
        
        overlay?.updateLeaderboard(times: finishedPlayers)
    }
    
    private func playerName(for id: String, fallback: String) -> String {
        scene.matchSystem?.match?.players.first(where: { $0.gamePlayerID == id })?.alias ?? fallback
    }
}
