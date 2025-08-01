//
//  HapticMapper.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import Foundation
import CoreHaptics

class HapticMapper {
    private var engine: CHHapticEngine?
    private var isEngineRunning = false
    private let patternManager = PhonemeVibePatternManager.shared
    
    init() {
        setupHapticEngine()
    }
    
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("Device does not support haptics")
            return
        }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            isEngineRunning = true
            
            // Restart the engine if it stops
            engine?.stoppedHandler = { [weak self] reason in
                print("Haptic engine stopped for reason: \(reason.rawValue)")
                self?.isEngineRunning = false
            }
            
            engine?.resetHandler = { [weak self] in
                print("Haptic engine reset")
                do {
                    try self?.engine?.start()
                    self?.isEngineRunning = true
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
        } catch {
            print("Failed to create and start haptic engine: \(error)")
        }
    }
    
    // Play haptic feedback for a single phoneme
    func playHapticForPhoneme(_ phoneme: String) {
        guard let pattern = patternManager.getPattern(for: phoneme) else {
            print("No pattern found for phoneme: \(phoneme)")
            return
        }
        
        playHapticPattern(pattern)
    }
    
    // Play a sequence of haptic patterns for a sequence of phonemes
    func playHapticSequence(for phonemes: [String]) {
        guard !phonemes.isEmpty else { return }
        
        var events: [CHHapticEvent] = []
        var timeOffset: TimeInterval = 0
        
        for phoneme in phonemes {
            guard let pattern = patternManager.getPattern(for: phoneme) else {
                // Skip phonemes without patterns
                continue
            }
            
            // Create intensity parameter
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: pattern.intensity)
            
            // Create sharpness parameter (using intensity as a proxy for sharpness)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: pattern.intensity)
            
            // Create haptic event
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: timeOffset)
            events.append(event)
            
            // Update time offset for next event
            timeOffset += pattern.duration + pattern.delay
        }
        
        // Play the sequence
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic sequence: \(error)")
        }
    }
    
    // Play a single haptic pattern
    func playHapticPattern(_ pattern: VibePattern) {
        guard isEngineRunning else {
            print("Haptic engine is not running")
            return
        }
        
        // Create intensity parameter
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: pattern.intensity)
        
        // Create sharpness parameter (using intensity as a proxy for sharpness)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: pattern.intensity)
        
        // Create haptic event
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }
    
    // Map phonemes to haptic patterns
    func mapPhonemes(_ phonemes: [String]) -> [VibePattern] {
        return phonemes.compactMap { phoneme in
            patternManager.getPattern(for: phoneme)
        }
    }
    
    // Send haptic pattern to connected BLE device
    func sendHapticToBLEDevice(_ pattern: VibePattern, peripheral: HapticPeripheral?) {
        guard let peripheral = peripheral else {
            print("No peripheral connected")
            return
        }
        
        let data = pattern.toData()
        peripheral.sendVibePattern(data)
    }
    
    // Send a sequence of haptic patterns to connected BLE device
    func sendHapticSequenceToBLEDevice(for phonemes: [String], peripheral: HapticPeripheral?) {
        guard let peripheral = peripheral, !phonemes.isEmpty else { return }
        
        for phoneme in phonemes {
            guard let pattern = patternManager.getPattern(for: phoneme) else {
                // Skip phonemes without patterns
                continue
            }
            
            let data = pattern.toData()
            peripheral.sendVibePattern(data)
            
            // Add delay between patterns
            Thread.sleep(forTimeInterval: pattern.duration + pattern.delay)
        }
    }
}