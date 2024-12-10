//Created by: Melissa Munoz

import Foundation
import Speech
import AVFoundation
import UIKit


class SpeechRecognizerManager: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var recognizedText: String = ""

    @Published var checklist: [ChecklistItem] = [
        ChecklistItem(name: "Seatbelt", isChecked: false),
        ChecklistItem(name: "Mirrors", isChecked: false),
        ChecklistItem(name: "Parallel Parking", isChecked: false),
        ChecklistItem(name: "Blind Spot", isChecked: false),
    ]
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var audioEngine = AVAudioEngine()
//    var audioPlayer: AVAudioPlayer?

    
    // Function to play a checkmark sound using NSDataAsset
//    func playCheckmarkSound() {
//        if let asset = NSDataAsset(name: "Validate") { // Make sure the name matches the asset name in the Assets folder
//            do {
//                // If a player is already playing, stop it first
//                audioPlayer?.stop()
//                audioPlayer = nil // Release the previous player
//                
//                // Use NSDataAsset's data property to access the audio file stored in Validate.wav.
//                audioPlayer = try AVAudioPlayer(data: asset.data, fileTypeHint: "wav")
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
    
    func startRecording() throws {
        // Check microphone permission before starting recording
        guard AVAudioSession.sharedInstance().recordPermission == .granted else {
            print("Microphone permission not granted.")
            return
        }

        isRecording = true

        // Cancel any previous recognition tasks
        recognitionTask?.cancel()
        recognitionTask = nil

        // Ensure the audio session is properly configured
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Set the audio session for recording with speech recognition
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("Audio session activated successfully.")
        } catch {
            print("Error activating audio session: \(error)")
            return
        }

        let inputNode = audioEngine.inputNode
        
        //Request the streamed audio object to the SFSpeechRecognizer (This is for audio streaming)
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let request = recognitionRequest else {
            print("Unable to create recognition request.")
            return
        }

        //Lets you get results through the audio stream
        request.shouldReportPartialResults = true

        //Represents the process of converting spoken audio into text
        self.recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
            if let err = error {
                print("Error during recognition task: \(err)")
                return
            }

            //Whether the recognition process is complete
            var isFinal = false

            //This is responsible for retrieving the text from the audio
            if let result = result {
                self.recognizedText = result.bestTranscription.formattedString
                isFinal = result.isFinal
                
                // MARK: Check for matches in the checklist
                            let recognizedText = result.bestTranscription.formattedString.lowercased()
                            
                            // Loop through the checklist items and check for matches
                            for index in self.checklist.indices {
                                if recognizedText.contains(self.checklist[index].name.lowercased()) {
                                    // If a match is found, mark the item as checked
                                    self.checklist[index].isChecked = true
//                                    self.playCheckmarkSound()  // Play the sound when an item is checked
                                }
                            }
                
            }

            if isFinal {
                self.stopRecording()
            }
        }

        // Install the audio tap
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }

        // Start the audio engine to capture the audio
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
        
        //Need to request microphone
        AVAudioSession.sharedInstance().requestRecordPermission { response in
            DispatchQueue.main.async {
                if response {
                    // Microphone permission granted
                    print("Microphone access granted")
                } else {
                    // Microphone permission denied
                    print("Microphone access denied")
                }
            }
        }
        
        //To use speech recognizer
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
