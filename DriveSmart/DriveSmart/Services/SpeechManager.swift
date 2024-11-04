//
//  SpeechManager.swift
//  DriveSmart
//
//  Created by Eli Munoz on 2024-10-29.
//

import Foundation
import AVFoundation

class SpeechService {
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    func speak(instruction: String, language: String = "en-US") {
        let utterance = AVSpeechUtterance(string: instruction)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        speechSynthesizer.speak(utterance)
    }
}
