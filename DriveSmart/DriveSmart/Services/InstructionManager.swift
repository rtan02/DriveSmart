//Created by: Melissa Munoz

import CoreLocation


class InstructionManager: ObservableObject {
    @Published var currentInstruction = "Adjust safety devices"
    
    private let speechManager: SpeechManager
    
    init(speechManager: SpeechManager) {
        self.speechManager = speechManager
    }
    
    func updateInstruction(with instruction: String) {
        currentInstruction = "\(instruction)"
        speechManager.speak(currentInstruction)
    }
}
