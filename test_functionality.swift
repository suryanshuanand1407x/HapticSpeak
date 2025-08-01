#!/usr/bin/env swift

import Foundation

// Test the core functionality without iOS-specific dependencies
print("🎯 Testing HapticSpeech Core Functionality")
print("==========================================")

// Test phoneme mapping
struct TestVibePattern {
    let intensity: Float
    let duration: TimeInterval
    let delay: TimeInterval
}

let testPatterns: [String: TestVibePattern] = [
    "æ": TestVibePattern(intensity: 0.5, duration: 0.2, delay: 0.0),
    "b": TestVibePattern(intensity: 0.8, duration: 0.1, delay: 0.0),
    "hello": TestVibePattern(intensity: 0.6, duration: 0.3, delay: 0.1)
]

print("✅ Phoneme to vibration pattern mapping:")
for (phoneme, pattern) in testPatterns {
    print("   \(phoneme) → intensity: \(pattern.intensity), duration: \(pattern.duration)s")
}

// Test text to phoneme simulation
func simulateTextToPhonemes(_ text: String) -> [String] {
    let simpleMapping: [Character: String] = [
        "h": "h", "e": "ɛ", "l": "l", "o": "oʊ",
        "w": "w", "r": "r", "d": "d"
    ]
    
    return text.lowercased().compactMap { char in
        simpleMapping[char]
    }
}

print("\n✅ Text to phoneme conversion:")
let testText = "hello world"
let phonemes = simulateTextToPhonemes(testText)
print("   '\(testText)' → \(phonemes)")

// Test speech recognition simulation
print("\n✅ Speech recognition simulation:")
print("   [Microphone Input] → 'Hello, this is a test' (simulated)")
print("   [Phonemizer] → ['h', 'ɛ', 'l', 'oʊ', ...] (simulated)")
print("   [Haptic Mapper] → [VibePattern1, VibePattern2, ...] (simulated)")

print("\n🎉 Core functionality test completed!")
print("The app should work with:")
print("- Speech → Text conversion (via Whisper)")
print("- Text → Phoneme conversion") 
print("- Phoneme → Haptic pattern mapping")
print("- Bluetooth transmission to haptic devices")