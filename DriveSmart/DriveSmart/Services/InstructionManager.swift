import CoreLocation


class InstructionManager: ObservableObject {
    @Published var currentInstruction = "Begin driving down the route."
    
    private let speechManager: SpeechManager
    
    init(speechManager: SpeechManager) {
        self.speechManager = speechManager
    }
    
    func updateInstruction(with instruction: String) {
        currentInstruction = "\(instruction)"
        speechManager.speak(currentInstruction)
    }
}