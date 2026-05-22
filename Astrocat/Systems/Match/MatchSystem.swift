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
    private var hasScheduledNextRound = false
    private var readyHeartbeatTimer: Timer?
    private var hostStartTimeoutTimer: Timer?
    
    var onRoundStartReceived: ((Int, UInt64, TimeInterval) -> Void)?
    var onPlayerUpdateReceived: ((GameMessage) -> Void)?
    var onPlayerFinishedReceived: ((GameMessage) -> Void)?
    var onFinalResultsReceived: (([RaceResult]) -> Void)?
    var onPresentViewController: (@MainActor (UIViewController) -> Void)?
    var onStartSolo: (@MainActor () -> Void)?
    var onStartMultiplayer: (@MainActor () -> Void)?
    var onPlayerDisconnected: ((String) -> Void)?

    
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
    func startMatch(mode: MatchMode) {
        switch mode {
        case .solo:
            onStartSolo?()
        case .multiplayer:
            let request = GKMatchRequest()
            request.minPlayers = 2
            request.maxPlayers = 4
            request.inviteMessage = "Race me in Astrocat! 🚀"

            guard let vc = GKMatchmakerViewController(matchRequest: request) else { return }
            vc.matchmakerDelegate = self
            onPresentViewController?(vc)
        }
    }

    
    func leaveMatch() {
        stopReadyHeartbeat()
        hostStartTimeoutTimer?.invalidate()
        hostStartTimeoutTimer = nil
        
        match?.disconnect()
        match = nil
        
        readyPlayersIDs.removeAll()
        hasSentGameStart = false
        hasScheduledNextRound = false
        isHost = false
        randomSeed = nil
        raceStarted = false
        playerTimes.removeAll()
        matchState = .authenticated
    }
    
    func localPlayerFinished(time: TimeInterval){
        let localID = GKLocalPlayer.local.gamePlayerID
        _ = GKLocalPlayer.local.alias
        playerTimes[localID] = time
        print("[MatchSystem] localPlayerFinished: time=\(time), currentRound=\(currentRound), playerTimes=\(playerTimes.count)")
        
        let msg = GameMessage.playerFinished(senderID: localID, finishTime: time)
        send(msg, with: .reliable)
        
        checkAndBroadcastFinalResults()
    }
    
    private func checkAndBroadcastFinalResults() {
        let expectedCount = (match?.players.count ?? 0) + 1
        print("[MatchSystem] checkAndBroadcastFinalResults: isHost=\(isHost), hasScheduled=\(hasScheduledNextRound), playerTimes=\(playerTimes.count)/\(expectedCount)")
        guard isHost, !hasScheduledNextRound else { return }
        guard playerTimes.count >= expectedCount else { return }
        
        hasScheduledNextRound = true
        print("[MatchSystem] All players finished round \(currentRound). Broadcasting results.")
        
        let sorted = playerTimes.sorted { $0.value < $1.value }
        let results = sorted.map { (id, time) in
            let playerName = match?.players.first(where: { $0.gamePlayerID == id })?.alias ?? (id == GKLocalPlayer.local.gamePlayerID ? GKLocalPlayer.local.alias : id)
            return RaceResult(senderID: id, playerName: playerName, finishTime: time)
        }
        let msg = GameMessage.finalResults(finalResults: results)
        send(msg, with: .reliable)
        onFinalResultsReceived?(results)
        
        let nextRound = currentRound + 1
        print("[MatchSystem] nextRound=\(nextRound), maxRounds=\(maxRounds), willSchedule=\(nextRound < maxRounds)")
        if nextRound < maxRounds {
            scheduleNextRound(index: nextRound)
        }
    }
    
    // MARK: Next Round Scheduling
    private func scheduleNextRound(index: Int) {
        print("[MatchSystem] scheduleNextRound(\(index)) — will fire in 3s")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else {
                print("[MatchSystem] scheduleNextRound(\(index)) — self is nil, MatchSystem deallocated")
                return
            }
            
            print("[MatchSystem] Firing roundStart for index=\(index), onRoundStartReceived is \(self.onRoundStartReceived == nil ? "nil" : "set")")
            
            self.hasScheduledNextRound = false
            self.playerTimes.removeAll()
            self.readyPlayersIDs.removeAll()
            self.currentRound = index
            self.matchState = .inGame
            
            let seed = UInt64.random(in: 0...UInt64.max)
            self.randomSeed = seed
            
            let epoch = Date().timeIntervalSince1970
            let msg = GameMessage.roundStart(
                senderID: GKLocalPlayer.local.gamePlayerID,
                roundIndex: index,
                randomSeed: seed,
                startTimeEpoch: epoch,
            )
            self.send(msg, with: .reliable)
            
            self.onRoundStartReceived?(index, seed, epoch)
            print("[MatchSystem] roundStart sent and onRoundStartReceived called for index=\(index)")
        }
    }
    
    // MARK: Ready Heartbeat
    func startReadyHeartbeat(){
        guard readyHeartbeatTimer == nil, !hasSentGameStart else { return }
        readyHeartbeatTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task {
                @MainActor [weak self] in
                self?.sendReadyHeartbeat()
            }
        }
    }

    private func stopReadyHeartbeat() {
        readyHeartbeatTimer?.invalidate()
        readyHeartbeatTimer = nil
    }
    
    func sendReadyHeartbeat(){
        let localID = GKLocalPlayer.local.gamePlayerID
        readyPlayersIDs.insert(localID)
        send(GameMessage.playerReady(senderID: localID), with: .reliable)
    }
    
    // MARK: Host Start Logic
    func tryStartIfHost(){
        guard isHost, match != nil, !hasSentGameStart, matchState == .inLobby else { return }
        
        scheduleHostStartTimeout()
        
        let expectedCount = (match?.players.count ?? 0) + 1
        if readyPlayersIDs.count >= expectedCount && match?.expectedPlayerCount == 0 {
            beginMatchStartBroadcast()
        }
        
    }
    
    private func scheduleHostStartTimeout(){
        guard hostStartTimeoutTimer == nil else { return }
        
        hostStartTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false){ [weak self] _ in
            Task { @MainActor [weak self] in
                self?.forceStartIfHost()
            }

        }
    }
    
    private func forceStartIfHost() {
        guard isHost, !hasSentGameStart else { return }
        guard let match = match, !match.players.isEmpty else { return }
        guard match.expectedPlayerCount == 0 else { return }
        beginMatchStartBroadcast()
    }
    
    private func beginMatchStartBroadcast() {
        let seed = UInt64.random(in: 0...UInt64.max)
        self.randomSeed = seed
        hasSentGameStart = true
        matchState = .inGame
        stopReadyHeartbeat()
        send(GameMessage.gameStart(randomSeed: seed), with: .reliable)
        
        onStartMultiplayer?()
    }
    
    
    // MARK: Sending Messages
    private func send(_ message: GameMessage, with mode: GKMatch.SendDataMode){
        guard let match = match else {return}
        do {
            let data = try JSONEncoder().encode(message)
            try match.sendData(toAllPlayers: data, with: mode)
        } catch {
            print("[MatchSystem] send error: \(error)")        }
    }
    
    func sendPlayerUpdate(_ message: GameMessage) {
        guard let match = match,
              let x = message.playerX, let y = message.playerY,
              let dx = message.playerDX, let dy = message.playerDY else { return }
        
        let packet = PositionPacket(x: Float(x), y: Float(y), dx: Float(dx), dy: Float(dy))
        let data = packet.toData()
        try? match.sendData(toAllPlayers: data, with: .unreliable)
    }
    
    // MARK: GKMatchDelegate
    nonisolated func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer){
        
        if data.first == 1, let packet = PositionPacket.from(data) {
            let msg = GameMessage(
                messageType: .playerUpdate,
                senderID: player.gamePlayerID,
                playerName: nil,
                playerX: CGFloat(packet.x),
                playerY: CGFloat(packet.y),
                playerDX: CGFloat(packet.dx),
                playerDY: CGFloat(packet.dy)
            )
            Task { @MainActor in
                self.onPlayerUpdateReceived?(msg)
            }
            return
        }
        
        Task {
            @MainActor in
            guard let message = try? JSONDecoder().decode(GameMessage.self, from: data) else {return}
            
            switch message.messageType {
            case .gameStart:
                guard matchState != .inGame else { return }
                randomSeed = message.randomSeed
                matchState = .inGame
                stopReadyHeartbeat()
                onStartMultiplayer?()
            case .playerReady:
                if !readyPlayersIDs.contains(player.gamePlayerID){
                    readyPlayersIDs.insert(player.gamePlayerID)
                }
                tryStartIfHost()
            case .playerFinished:
                if let id = message.senderID, let time = message.finishTime {
                    playerTimes[id] = time
                    print("[MatchSystem] Received playerFinished from \(id), time=\(time), playerTimes=\(playerTimes.count)")
                }
                var enriched = message
                enriched.playerName = player.displayName
                onPlayerFinishedReceived?(enriched)
                checkAndBroadcastFinalResults()
                
            case .playerUpdate:
                onPlayerUpdateReceived?(message)
                
            case .finalResults:
                if let results = message.finalResults {
                    print("[MatchSystem] Received finalResults, count=\(results.count), onFinalResultsReceived is \(onFinalResultsReceived == nil ? "nil" : "set")")
                    onFinalResultsReceived?(results)
                }
            case .roundStart:
                if let round = message.roundIndex,
                   let seed = message.randomSeed,
                   let epoch = message.startTimeEpoch {
                    print("[MatchSystem] Received roundStart: round=\(round), onRoundStartReceived is \(onRoundStartReceived == nil ? "nil" : "set")")
                    playerTimes.removeAll()
                    readyPlayersIDs.removeAll()
                    currentRound = round
                    randomSeed = seed
                    onRoundStartReceived?(round, seed, epoch)
                }
                
            }
        }
        
    }
    
    nonisolated func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        guard state == .disconnected else { return }
        Task { @MainActor [weak self] in
            self?.onPlayerDisconnected?(player.gamePlayerID)
            self?.leaveMatch()
        }
    }
    
    nonisolated func match(_ match: GKMatch, didFailWithError error: Error?) {
        Task { @MainActor [weak self] in
            self?.leaveMatch()
        }
    }
    
    
    // MARK: GKLocalPlayerListener
    nonisolated func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            guard let vc = GKMatchmakerViewController(invite: invite) else { return }
            vc.matchmakerDelegate = self
            self.onPresentViewController?(vc)
        }
    }
    
    // MARK: GKMatchMakerViewControllerDelegate
    nonisolated func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        Task { @MainActor [weak self] in
            self?.matchState = .authenticated 
            viewController.dismiss(animated: true)
        }
    }
    
    nonisolated func matchmakerViewController(
        _ viewController: GKMatchmakerViewController,
        didFailWithError error: any Error
    ) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            viewController.dismiss(animated: true)
            self.lastErrorMessage = error.localizedDescription
            self.matchState = .authenticated
        }
    }
    
    nonisolated func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        match.delegate = self
        Task {
            @MainActor in
            viewController.dismiss(animated: true)
            self.match = match
            readyPlayersIDs.removeAll()
            hasSentGameStart = false

            let allPlayers = match.players + [GKLocalPlayer.local]
            let sortedIDs = allPlayers.map { $0.gamePlayerID }.sorted()
            self.isHost = sortedIDs.first == GKLocalPlayer.local.gamePlayerID
            matchState = .inLobby
            startReadyHeartbeat()
        }

    }
    
    nonisolated private struct PositionPacket {
        var type: UInt8 = 1
        var x: Float
        var y: Float
        var dx: Float
        var dy: Float
        
//        func toData() -> Data {
//            var copy = self
//            return Data(bytes: &copy, count: MemoryLayout<PositionPacket>.size)
//        }
//        
//        static func from(_ data: Data) -> PositionPacket? {
//            guard data.count >= MemoryLayout<PositionPacket>.size,
//                  data[0] == 1 else { return nil }
//            return data.withUnsafeBytes { $0.loadUnaligned(as: PositionPacket.self) }
//        }
        
        func toData() -> Data {
            var data = Data(capacity: 17)
            data.append(type)
            withUnsafeBytes(of: x.bitPattern.bigEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: y.bitPattern.bigEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: dx.bitPattern.bigEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: dy.bitPattern.bigEndian) { data.append(contentsOf: $0) }
            return data
        }

        static func from(_ data: Data) -> PositionPacket? {
            guard data.count == 17, data[0] == 1 else { return nil }
            let x  = Float(bitPattern: UInt32(bigEndian: data[1...4].withUnsafeBytes  { $0.loadUnaligned(as: UInt32.self) }))
            let y  = Float(bitPattern: UInt32(bigEndian: data[5...8].withUnsafeBytes  { $0.loadUnaligned(as: UInt32.self) }))
            let dx = Float(bitPattern: UInt32(bigEndian: data[9...12].withUnsafeBytes { $0.loadUnaligned(as: UInt32.self) }))
            let dy = Float(bitPattern: UInt32(bigEndian: data[13...16].withUnsafeBytes { $0.loadUnaligned(as: UInt32.self) }))
            return PositionPacket(type: 1, x: x, y: y, dx: dx, dy: dy)
        }
    }
}
