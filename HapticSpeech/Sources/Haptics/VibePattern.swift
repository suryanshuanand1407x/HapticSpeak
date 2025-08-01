//
//  VibePattern.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import Foundation

struct VibePattern: Codable, Equatable {
    let intensity: Float // 0.0 to 1.0
    let duration: TimeInterval // in seconds
    let delay: TimeInterval // in seconds
    
    init(intensity: Float, duration: TimeInterval, delay: TimeInterval) {
        // Clamp intensity to valid range
        self.intensity = min(max(intensity, 0.0), 1.0)
        self.duration = max(duration, 0.0)
        self.delay = max(delay, 0.0)
    }
    
    // Create a pattern with a specific preset
    static func preset(_ type: PatternType) -> VibePattern {
        switch type {
        case .light:
            return VibePattern(intensity: 0.3, duration: 0.2, delay: 0.1)
        case .medium:
            return VibePattern(intensity: 0.6, duration: 0.3, delay: 0.1)
        case .strong:
            return VibePattern(intensity: 0.9, duration: 0.4, delay: 0.1)
        case .quick:
            return VibePattern(intensity: 0.7, duration: 0.1, delay: 0.05)
        case .long:
            return VibePattern(intensity: 0.5, duration: 0.5, delay: 0.2)
        }
    }
    
    // Pattern presets
    enum PatternType {
        case light
        case medium
        case strong
        case quick
        case long
    }
    
    // Convert to data for BLE transmission
    func toData() -> Data {
        var data = Data(capacity: 12)
        
        // Intensity (0-255)
        let intensityByte = UInt8(intensity * 255)
        data.append(intensityByte)
        
        // Duration (milliseconds, 16-bit)
        let durationMs = UInt16(duration * 1000)
        data.append(UInt8(durationMs & 0xFF))
        data.append(UInt8((durationMs >> 8) & 0xFF))
        
        // Delay (milliseconds, 16-bit)
        let delayMs = UInt16(delay * 1000)
        data.append(UInt8(delayMs & 0xFF))
        data.append(UInt8((delayMs >> 8) & 0xFF))
        
        return data
    }
    
    // Create a pattern from BLE data
    static func fromData(_ data: Data) -> VibePattern? {
        guard data.count >= 5 else { return nil }
        
        let intensityByte = data[0]
        let intensity = Float(intensityByte) / 255.0
        
        let durationLow = data[1]
        let durationHigh = data[2]
        let durationMs = UInt16(durationLow) | (UInt16(durationHigh) << 8)
        let duration = TimeInterval(durationMs) / 1000.0
        
        let delayLow = data[3]
        let delayHigh = data[4]
        let delayMs = UInt16(delayLow) | (UInt16(delayHigh) << 8)
        let delay = TimeInterval(delayMs) / 1000.0
        
        return VibePattern(intensity: intensity, duration: duration, delay: delay)
    }
}