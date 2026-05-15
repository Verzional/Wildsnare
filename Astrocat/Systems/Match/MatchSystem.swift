//
//  MatchSystem.swift
//  Astrocat
//
//  Created by Arya on 13/05/26.
//

import GameKit
import Combine

@MainActor
class MatchSystem: NSObject, ObservableObject, GKMatchDelegate, GKLocalPlayerListener, GKMatchmakerViewControllerDelegate {
    
    // MARK: Properties
    @Published var matchState: MatchManagerState = .unauthenticated
    @Published var lastErrorMessage: String?
    @Published var isHost: Bool = false
    @Published var currentRound: Int = 0
    @Published var randomSeed: UInt64?
    @Published var raceStarted: Bool = false
    @Published var playerTimes: [String: TimeInterval] = [:]
    
    var match: GKMatch?
    var readyPlayersIDs = Set<String>()
    var hasSentGameStart = false
    private var readyHeartbeatTimer: Timer?
    private var hostStartTimeoutTimer: Timer?
    
    var onRoundStartReceived: ((Int, UInt64, TimeInterval) -> Void)?
    var onPlayerUpdateReceived: ((GameMessage) -> Void)?
    var onPlayerFinishedReceived: ((GameMessage) -> Void)?
    var onFinalResultsReceived: (([RaceResult]) -> Void)?
    var onPresentViewController: ((UIViewController) -> Void)?

    
    // MARK: Authentication
    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = {
            [weak self] vc, error in
                guard let self = self else { return }
                
                if let vc = vc {
                    self.onPresentViewController?(vc)
                    return
                    
                }
                
                if error != nil {
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        self.lastErrorMessage = error?.localizedDescription
                        self.matchState = .unauthenticated
                    }
                    return
                }
                
                if GKLocalPlayer.local.isAuthenticated {
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        self.matchState = .authenticated
                        GKLocalPlayer.local.register(self)
                    }
                }
        }
    }
    
    // MARK: Match Lifecycle
    func startMatch(mode: MatchMode){
        let request = GKMatchRequest()
        
        switch mode {
        case .quickMatch (let playerCount):
            request.minPlayers = 2
            request.maxPlayers = playerCount
        case .inviteFriend (let playerCount):
            request.minPlayers = 2
            request.maxPlayers = playerCount
            break
        }
        
        request.inviteMessage = "Join me in a Astrocat!"
        
        let viewController = GKMatchmakerViewController(matchRequest: request)
        guard let vc = viewController else { return }
        vc.matchmakerDelegate = self
        
        onPresentViewController?(vc)
        
    }
    
    func leaveMatch(){
        
    }
    
    func localPlayerFinished(time: TimeInterval){
        
    }
    
    // MARK: Sending Messages
    private func sendReliable(_ message: GameMessage){}
    private func sendUnreliable(_ message: GameMessage){}
    
    // MARK: GKMatchDelegate
    nonisolated func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer){}
    
    nonisolated func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState){}
    
    nonisolated func match(_ match: GKMatch, didFailWithError error: Error?){}
    
    // MARK: GKLocalPlayerListener
    nonisolated func player(_ player: GKPlayer, didAccept invite: GKInvite){}
    
    // MARK: GKMatchMakerViewControllerDelegate
    nonisolated func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        
    }
    
    nonisolated func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: any Error) {
    }
    
    nonisolated func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        
        Task {
            @MainActor in
            viewController.dismiss(animated: true)
            self.match = match
            match.delegate = self
            readyPlayersIDs.removeAll()
            hasSentGameStart = false

            let allPlayers = match.players + [GKLocalPlayer.local]
            let sortedIDs = allPlayers.map { $0.gamePlayerID }.sorted()
            self.isHost = sortedIDs.first == GKLocalPlayer.local.gamePlayerID
            
            matchState = .inLobby
        }
    }
    
    
    
    
}
