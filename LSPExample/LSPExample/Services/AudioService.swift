//
//  AudioService.swift
//  LSPExample
//
//  Created by Joshua Browne on 29/05/2025.
//

import Foundation
import AVFoundation

final class AudioService {
    static let shared = AudioService()
    private var players: [String: AVAudioPlayer] = [:]

    /// Play a sound by its filename (must be in bundle).
    func play(soundFileName: String) {
        if let player = players[soundFileName], player.isPlaying {
            player.stop()
        }

        guard let url = Bundle.main.url(forResource: soundFileName, withExtension: nil) else {
            print("🔊 Audio file \(soundFileName) not found.")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            players[soundFileName] = player
            player.prepareToPlay()
            player.play()
        } catch {
            print("🔊 Failed to play \(soundFileName): \(error)")
        }
    }
}
