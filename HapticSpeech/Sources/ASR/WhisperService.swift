//
//  WhisperService.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import Foundation
import AVFoundation
import Combine

class WhisperService: ObservableObject {
    // MARK: - Published Properties
    @Published var isProcessing = false
    @Published var recognizedText = ""
    @Published var errorMessage: String? = nil
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let whisperModelURL: URL?
    private var useOnDeviceRecognition = true
    private var selectedLanguage = "en" // Default to English
    
    // MARK: - Initialization
    init() {
        // Look for the Whisper model in the app bundle
        whisperModelURL = Bundle.main.url(forResource: "whisper-tiny", withExtension: "mlmodel", subdirectory: "Models")
    }
    
    // MARK: - Public Methods
    
    /// Process audio data and convert it to text using Whisper
    /// - Parameters:
    ///   - audioData: The audio data to process
    ///   - completion: Completion handler with Result<String, Error>
    func processAudio(_ audioData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        isProcessing = true
        errorMessage = nil
        
        // Check if we should use on-device recognition
        if useOnDeviceRecognition {
            processAudioOnDevice(audioData, completion: completion)
        } else {
            processAudioWithAPI(audioData, completion: completion)
        }
    }
    
    /// Set whether to use on-device recognition or API
    /// - Parameter useOnDevice: True to use on-device, false to use API
    func setUseOnDeviceRecognition(_ useOnDevice: Bool) {
        useOnDeviceRecognition = useOnDevice
    }
    
    /// Set the language for recognition
    /// - Parameter languageCode: The ISO language code (e.g., "en", "fr")
    func setLanguage(_ languageCode: String) {
        selectedLanguage = languageCode
    }
    
    // MARK: - Private Methods
    
    /// Process audio on-device using the Whisper model
    private func processAudioOnDevice(_ audioData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        // Check if the model is available
        guard let modelURL = whisperModelURL else {
            completion(.failure(NSError(domain: "WhisperService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Whisper model not found"])))
            return
        }
        
        // In a real implementation, this would use the Whisper model to process the audio
        // For now, we'll simulate the processing with a delay
        DispatchQueue.global().async { [weak self] in
            // Simulate processing time
            Thread.sleep(forTimeInterval: 1.0)
            
            // Simulate a result
            let result = "This is a simulated transcription from the Whisper model."
            DispatchQueue.main.async {
                self?.isProcessing = false
                self?.recognizedText = result
                completion(.success(result))
            }
        }
    }
    
    /// Process audio using the Whisper API
    private func processAudioWithAPI(_ audioData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        // In a real implementation, this would send the audio to the Whisper API
        // For now, we'll simulate the API call with a delay
        DispatchQueue.global().async { [weak self] in
            // Simulate network delay
            Thread.sleep(forTimeInterval: 2.0)
            
            // Simulate a result
            let result = "This is a simulated transcription from the Whisper API."
            DispatchQueue.main.async {
                self?.isProcessing = false
                self?.recognizedText = result
                completion(.success(result))
            }
        }
    }
    
    /// Handle errors during processing
    private func handleError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.isProcessing = false
            self?.errorMessage = message
        }
    }
    
    /// Convert WAV audio to the format required by Whisper
    private func convertAudioForWhisper(_ audioData: Data) -> Data? {
        // In a real implementation, this would convert the audio to the format required by Whisper
        // For now, we'll just return the original data
        return audioData
    }
}