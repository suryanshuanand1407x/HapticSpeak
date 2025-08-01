//
//  HomeViewModel.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    // Audio session manager for handling microphone access
    private let audioSessionManager = AudioSessionManager()
    private let audioBufferManager = AudioBufferManager()
    
    // ASR services
    private let whisperService = WhisperService()
    private let phonemizerService = PhonemizerService()
    
    // Haptic services
    private let hapticMapper = HapticMapper()
    
    // Bluetooth connectivity
    private let bleManager = BLEManager()
    
    // Published properties for UI updates
    @Published var isRecording = false
    @Published var isProcessing = false
    @Published var recognizedText = ""
    @Published var currentPhonemes: [String] = []
    @Published var connectionStatus = "Disconnected"
    
    // Cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Subscribe to BLE connection status changes
        bleManager.$connectionState
            .receive(on: DispatchQueue.main)
            .map { state -> String in
                switch state {
                case .connected: return "Connected"
                case .connecting: return "Connecting..."
                case .disconnected: return "Disconnected"
                case .scanning: return "Scanning..."
                }
            }
            .assign(to: &$connectionStatus)
    }
    
    func toggleRecording() {
        print("🎤 toggleRecording called - isRecording: \(isRecording)")
        if isRecording {
            print("🛑 Stopping recording...")
            stopRecording()
        } else {
            print("▶️ Starting recording...")
            startRecording()
        }
    }
    
    private func startRecording() {
        print("🎵 startRecording called")
        // Request microphone permissions and start audio capture
        audioSessionManager.requestRecordPermission { [weak self] granted in
            print("🔐 Microphone permission result: \(granted)")
            guard let self = self, granted else { 
                print("❌ Microphone permission denied")
                return 
            }
            
            print("✅ Microphone permission granted, activating session...")
            // Activate audio session before starting recording
            self.audioSessionManager.activateAudioSession()
            
            print("🔴 Setting isRecording = true and starting buffer manager...")
            DispatchQueue.main.async {
                self.isRecording = true
                self.recognizedText = ""
            }
            
            self.audioBufferManager.startRecording()
            print("📱 AudioBufferManager.startRecording() called")
        }
    }
    
    private func stopRecording() {
        isRecording = false
        isProcessing = true
        
        // Stop recording and process the audio
        if let audioBuffer = audioBufferManager.stopRecording() {
            // Deactivate audio session after stopping recording
            audioSessionManager.deactivateAudioSession()
            // Process audio with Whisper for speech recognition
            self.whisperService.processAudio(audioBuffer) { result in
                switch result {
                case .success(let text):
                    self.processRecognizedText(text)
                case .failure(let error):
                    print("Speech recognition error: \(error)")
                    DispatchQueue.main.async {
                        self.isProcessing = false
                    }
                }
            }
        } else {
            print("No audio data captured")
            DispatchQueue.main.async {
                self.isProcessing = false
            }
        }
    }
    
    private func processRecognizedText(_ text: String) {
        DispatchQueue.main.async {
            self.recognizedText = text
        }
        
        // Convert text to phonemes
        phonemizerService.textToPhonemes(text) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let phonemes):
                self.processPhonemes(phonemes)
            case .failure(let error):
                print("Phonemizer error: \(error)")
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
            }
        }
    }
    
    private func processPhonemes(_ phonemes: [String]) {
        DispatchQueue.main.async {
            self.currentPhonemes = phonemes
        }
        
        // Map phonemes to haptic patterns
        let patterns = hapticMapper.mapPhonemes(phonemes)
        
        // Send patterns to connected device if available
        if bleManager.connectionState == .connected {
            bleManager.sendHapticPatterns(patterns)
        }
        
        DispatchQueue.main.async {
            self.isProcessing = false
        }
        
        // Log the session
        let sessionLog = SessionLog(
            id: UUID(),
            timestamp: Date(),
            duration: 2.0, // Approximate duration in seconds (could be calculated from actual recording time)
            recognizedText: recognizedText,
            phonemes: phonemes,
            hapticPatternsCount: patterns.count
        )
        
        // Save session log (implementation would be in a repository class)
        print("Session logged: \(sessionLog)")
    }
    
    func connectToDevice() {
        bleManager.startScanning()
    }
}
