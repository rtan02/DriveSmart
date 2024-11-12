//Created by: Melissa Munoz

import Foundation
import Speech
import AVFoundation

class SpeechRecognizerManager: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var recognizedText: String = ""
    
    @Published var checklist: [ChecklistItem] = [
        ChecklistItem(name: "Seatbelt", isChecked: false),
        ChecklistItem(name: "Parallel Parking", isChecked: false),
        ChecklistItem(name: "Left", isChecked: false)
    ]
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    
    func startRecording() throws {
        isRecording = true
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .spokenAudio, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let request = recognitionRequest else {
            print(#function, "Unable to create request due to error")
            return
        }
        
        request.shouldReportPartialResults = true
        
        self.recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
            if let err = error {
                print(#function, "Unable to create recognitionTask due to error \(err)")
                return
            }
            
            var isFinal = false
            
            if let result = result {
                self.recognizedText = result.bestTranscription.formattedString
                isFinal = result.isFinal
                
                // MARK: Check for matches in the checklist
                let recognizedText = result.bestTranscription.formattedString.lowercased()
                for index in self.checklist.indices {
                    if recognizedText.contains(self.checklist[index].name.lowercased()) {
                        self.checklist[index].isChecked = true
                    }
                }
            }
            
            if isFinal {
                self.stopRecording()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isRecording = false
        recognitionTask = nil
        recognitionRequest = nil
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    // Permission granted
                    print("Speech recognition authorized.")
                case .denied:
                    // Permission denied
                    print("Speech recognition permission denied.")
                    self.recognizedText = "Speech recognition permission was denied."
                case .restricted:
                    // Speech recognition restricted on this device
                    print("Speech recognition restricted.")
                    self.recognizedText = "Speech recognition is restricted on this device."
                case .notDetermined:
                    // Permission not yet determined
                    print("Speech recognition permission not determined.")
                    self.recognizedText = "Speech recognition permission not determined."
                @unknown default:
                    // Handle any new cases that might be added in the future
                    print("Unknown authorization status.")
                    self.recognizedText = "Unknown authorization status."
                }
            }
        }
    }
    
}
