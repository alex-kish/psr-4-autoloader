import Foundation
import AVFoundation

final class SoundPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var audioPlayers: [AVAudioPlayer] = []

    func play(url: URL) {
        Task {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                await MainActor.run {
                    player.delegate = self
                    self.audioPlayers.append(player)
                    player.play()
                }
            } catch {
                print("Could not create audio player: \(error)")
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.audioPlayers.removeAll(where: { $0 === player })
    }
} 