//
//import CoreLocation
//
//class InstructionManager: ObservableObject {
//    @Published var instructionIndex = 0
//    @Published var currentInstruction = "Proceed to the start location."
//    
//    private let speechManager: SpeechManager
//
//    init(speechManager: SpeechManager) {
//           self.speechManager = speechManager
//       }
//    
//    var instructions = [
//        "Check your seatbelt, mirror and seats",
//        "Turn left at the next intersection.",
//        "Continue on Third Line.",
//        "Make a right at Kings College Dr.",
//        "Proceed to Grainer Court.",
//        "Take a left onto Blacksmith Ln.",
//        "Head back to King's College Dr.",
//        "Continue straight to Third Line.",
//        "Finish at the Test Center."
//    ]
//    
//    func updateInstruction() {
//        if instructionIndex < instructions.count - 1 {
//            instructionIndex += 1
//            currentInstruction = instructions[instructionIndex]
//        } else {
//            currentInstruction = "Route completed."
//        }
//        speechManager.speak(currentInstruction)
//    }
//}

import CoreLocation

class InstructionManager: ObservableObject {
    @Published var instructionIndex = 0
    @Published var currentInstruction = "Proceed to the start location."
    
    private let speechManager: SpeechManager
    var instructions: [String]
    
    init(speechManager: SpeechManager, instructions: [String] = []) {
        self.speechManager = speechManager
        self.instructions = instructions.isEmpty ? ["No instructions available."] : instructions
    }
    
    func setInstructions(_ newInstructions: [String]) {
        instructions = newInstructions
        instructionIndex = 0
        currentInstruction = instructions.first ?? "No instructions available."
    }
    
    func updateInstruction() {
        if instructionIndex < instructions.count - 1 {
            instructionIndex += 1
            currentInstruction = instructions[instructionIndex]
        } else {
            currentInstruction = "Route completed."
        }
        speechManager.speak(currentInstruction)
    }
   
}
