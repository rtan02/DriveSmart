//Created by: Melissa Munoz

import AVFoundation
import SwiftUI

class SpeechManager: ObservableObject {
    private var synthesizer = AVSpeechSynthesizer()
    
    func speak(_ instruction: String) {
        
        // Stop speaking if already in progress
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: instruction)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5  
        
        synthesizer.speak(utterance)
    }
    
    // This function stops the speech if needed
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
