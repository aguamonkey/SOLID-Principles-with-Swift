import AVFoundation

/// Optional sample playback is independent of the Playable contract.
/// Previewing one instrument replaces the previous preview.
final class AudioService {
    private var player: AVAudioPlayer?

    @discardableResult
    func play(soundFileName: String) -> String? {
        stop()
        guard let url = Bundle.main.url(forResource: soundFileName, withExtension: nil) else {
            return "This instrument's audio preview is unavailable."
        }
        do {
            let next = try AVAudioPlayer(contentsOf: url)
            guard next.prepareToPlay(), next.play() else {
                return "The audio preview could not start."
            }
            player = next
            return nil
        } catch {
            return "The audio preview could not be opened."
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }
}
