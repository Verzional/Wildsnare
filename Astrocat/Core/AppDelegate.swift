//
//  AppDelegate.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 30/04/26.
//

import UIKit
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
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") ?? Bundle.main.url(forResource: soundName, withExtension: "mp3", subdirectory: "Sound/BGM") else {
            print("Could not find \(soundName).mp3")
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
            print("Failed to play BGM: \(error.localizedDescription)")
        }
    }
    
    func stopBGM() {
        bgmPlayer?.stop()
        currentSong = nil
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

