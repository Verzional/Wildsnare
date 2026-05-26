import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    
    private var bgmPlayer: AVAudioPlayer?
    private var currentSong: String?
    
    private init() {}
    
    enum BGM: String {
        case home = "Home"
        case earth = "Earth"
        case sky = "Sky"
        case space = "Space"
    }
    
    func playBGM(_ bgm: BGM) {
        let soundName = bgm.rawValue
        
        if currentSong == soundName { return }
        if let player = bgmPlayer, player.isPlaying {
            player.stop()
        }
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
//            print("Could not find \(soundName).mp3")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            bgmPlayer = try AVAudioPlayer(contentsOf: url)
            bgmPlayer?.numberOfLoops = -1
            bgmPlayer?.volume = 0.5
            bgmPlayer?.play()
            currentSong = soundName
        } catch {
//            print("Failed to play BGM: \(error.localizedDescription)")
        }
    }
    
    func stopBGM() {
        bgmPlayer?.stop()
        currentSong = nil
    }
}
