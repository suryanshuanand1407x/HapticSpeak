//
//  AudioSessionManager.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import Foundation
import AVFoundation
import Combine

class AudioSessionManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isSessionActive = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let session = AVAudioSession.sharedInstance()
    
    // MARK: - Initialization
    init() {
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    /// Activate the audio session for recording
    func activateAudioSession() {
        do {
            // Configure the audio session for recording
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Update the session status
            isSessionActive = true
            errorMessage = nil
        } catch {
            handleError("Failed to activate audio session: \(error.localizedDescription)")
        }
    }
    
    /// Deactivate the audio session
    func deactivateAudioSession() {
        do {
            try session.setActive(false, options: .notifyOthersOnDeactivation)
            isSessionActive = false
        } catch {
            handleError("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    /// Request permission to record audio
    func requestRecordPermission(completion: @escaping (Bool) -> Void) {
        session.requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Set up notifications for audio session interruptions
    private func setupNotifications() {
        // Listen for audio session interruptions (e.g., phone calls)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        // Listen for route changes (e.g., headphones connected/disconnected)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }
    
    /// Handle audio session interruptions
    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Interruption began, update UI accordingly
            DispatchQueue.main.async { [weak self] in
                self?.isSessionActive = false
            }
            
        case .ended:
            // Interruption ended, check if we should resume
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt,
               AVAudioSession.InterruptionOptions(rawValue: optionsValue).contains(.shouldResume) {
                // Try to reactivate the session
                activateAudioSession()
            }
            
        @unknown default:
            break
        }
    }
    
    /// Handle audio route changes
    @objc private func handleAudioRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .newDeviceAvailable:
            // New audio device became available (e.g., headphones connected)
            print("New audio device connected")
            
        case .oldDeviceUnavailable:
            // Audio device became unavailable (e.g., headphones disconnected)
            print("Audio device disconnected")
            
        default:
            break
        }
    }
    
    /// Handle errors during audio session operations
    private func handleError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = message
            self?.isSessionActive = false
        }
    }
}