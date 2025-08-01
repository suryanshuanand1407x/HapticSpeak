//
//  AudioBufferManager.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import Foundation
import AVFoundation
import Combine

class AudioBufferManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isRecording = false
    @Published var audioLevel: Float = 0.0
    @Published var errorMessage: String? = nil
    
    // MARK: - Private Properties
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var audioBuffer = Data()
    private var audioFormat: AVAudioFormat?
    private var cancellables = Set<AnyCancellable>()
    
    // Audio level monitoring
    private var levelTimer: Timer?
    private let audioLevelUpdateInterval: TimeInterval = 0.1
    
    // MARK: - Initialization
    init() {
        setupAudioEngine()
    }
    
    deinit {
        stopRecording()
        levelTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    /// Start recording audio
    func startRecording() {
        print("🎙️ AudioBufferManager.startRecording() - isRecording: \(isRecording)")
        guard !isRecording else { 
            print("⚠️ Already recording, returning early")
            return 
        }
        
        // Clear previous buffer
        audioBuffer.removeAll()
        print("🗑️ Cleared previous audio buffer")
        
        do {
            print("🚀 Starting audio engine...")
            try startAudioEngine()
            isRecording = true
            startAudioLevelMonitoring()
            print("✅ Recording started successfully")
        } catch {
            print("❌ Failed to start recording: \(error)")
            handleError("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    /// Stop recording and return the audio buffer
    func stopRecording() -> Data? {
        guard isRecording else { return nil }
        
        stopAudioEngine()
        isRecording = false
        stopAudioLevelMonitoring()
        
        return audioBuffer.isEmpty ? nil : audioBuffer
    }
    
    // MARK: - Private Methods
    
    /// Set up the audio engine and input node
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine?.inputNode
        
        // Configure the audio format for recording
        audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                   sampleRate: 16000,
                                   channels: 1,
                                   interleaved: false)
    }
    
    /// Start the audio engine and install tap on input node
    private func startAudioEngine() throws {
        print("🔧 startAudioEngine called")
        guard let audioEngine = audioEngine,
              let inputNode = inputNode,
              let audioFormat = audioFormat else {
            let error = NSError(domain: "AudioBufferManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Audio engine not properly initialized"])
            print("❌ Audio engine not properly initialized: \(error)")
            throw error
        }
        
        print("⚙️ Audio engine components initialized, preparing...")
        // Prepare and start the audio engine first
        audioEngine.prepare()
        print("🔄 Audio engine prepared, starting...")
        try audioEngine.start()
        print("🚀 Audio engine started successfully")
        
        // Install a tap on the input node to capture audio after engine is started
        print("🔌 Installing tap on input node...")
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: audioFormat) { [weak self] buffer, time in
            self?.processAudioBuffer(buffer)
        }
        print("✅ Tap installed successfully")
    }
    
    /// Stop the audio engine and remove tap
    private func stopAudioEngine() {
        guard let audioEngine = audioEngine,
              let inputNode = inputNode else { return }
        
        inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
    
    /// Process audio buffer from the tap
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0],
              let audioFormat = audioFormat else { return }
        
        // Convert buffer to Data
        let frameCount = Int(buffer.frameLength)
        let dataSize = frameCount * MemoryLayout<Float>.size
        let data = Data(bytes: channelData, count: dataSize)
        
        // Append to our audio buffer
        audioBuffer.append(data)
    }
    
    /// Start monitoring audio levels
    private func startAudioLevelMonitoring() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: audioLevelUpdateInterval, repeats: true) { [weak self] _ in
            self?.updateAudioLevel()
        }
    }
    
    /// Stop monitoring audio levels
    private func stopAudioLevelMonitoring() {
        levelTimer?.invalidate()
        levelTimer = nil
        audioLevel = 0.0
    }
    
    /// Update the current audio level
    private func updateAudioLevel() {
        guard let audioEngine = audioEngine,
              let inputNode = inputNode else { return }
        
        // Get the peak power from the audio engine's input node
        let level = inputNode.volume
        
        // Update the published audio level
        DispatchQueue.main.async { [weak self] in
            self?.audioLevel = level
        }
    }
    
    /// Handle errors during audio processing
    private func handleError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = message
        }
    }
}