//Created by: Melissa Munoz

import AVFoundation
import SwiftUI

class SpeechManager: ObservableObject {
    private var synthesizer = AVSpeechSynthesizer()
//    private var audioPlayer: AVAudioPlayer?

    
    func speak(_ instruction: String) {
        
        // Stop speaking if already in progress
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: instruction)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5  
        
        synthesizer.speak(utterance)
//        playSilentSound()
    }
    
    // This function stops the speech if needed
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
//    func playSilentSound() {
//        if let asset = NSDataAsset(name: "silence") { // Make sure the name matches the asset name in the Assets folder
//            do {
//                // If a player is already playing, stop it first
//                audioPlayer?.stop()
//                audioPlayer = nil // Release the previous player
//                
//                // Use NSDataAsset's data property to access the audio file stored in silence.mp3.
//                audioPlayer = try AVAudioPlayer(data: asset.data, fileTypeHint: "mp3")
//                
//                // Play the sound.
//                audioPlayer?.play()
//            } catch let error as NSError {
//                print("Error playing checkmark sound: \(error.localizedDescription)")
//            }
//        } else {
//            print("Validate.wav sound asset not found.")
//        }
//    }
}
