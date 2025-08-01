//
//  PhonemeVibePattern.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import Foundation

// Structure to match the DefaultMappings.json format
struct DefaultMappingsJSON: Codable {
    let phonemePatterns: [DefaultMappingPattern]
}

struct DefaultMappingPattern: Codable {
    let id: String
    let phoneme: String
    let pattern: VibePattern
}

struct PhonemeVibePattern: Identifiable, Codable {
    let id: UUID
    let phoneme: String
    let pattern: VibePattern
    
    init(id: UUID = UUID(), phoneme: String, pattern: VibePattern) {
        self.id = id
        self.phoneme = phoneme
        self.pattern = pattern
    }
}

class PhonemeVibePatternManager {
    static let shared = PhonemeVibePatternManager()
    
    private(set) var mappings: [PhonemeVibePattern] = []
    private let defaultMappingsURL: URL
    private let userMappingsURL: URL
    
    private init() {
        // Get URL for the default mappings in the app bundle
        guard let bundleURL = Bundle.main.url(forResource: "DefaultMappings", withExtension: "json") else {
            fatalError("DefaultMappings.json not found in bundle")
        }
        defaultMappingsURL = bundleURL
        
        // Get URL for user-customized mappings in the documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        userMappingsURL = documentsDirectory.appendingPathComponent("UserMappings.json")
        
        loadMappings()
    }
    
    func loadMappings() {
        // First try to load user mappings, if they exist
        if FileManager.default.fileExists(atPath: userMappingsURL.path) {
            do {
                let data = try Data(contentsOf: userMappingsURL)
                mappings = try JSONDecoder().decode([PhonemeVibePattern].self, from: data)
                return
            } catch {
                print("Failed to load user mappings: \(error)")
                // Fall back to default mappings
            }
        }
        
        // Load default mappings
        do {
            let data = try Data(contentsOf: defaultMappingsURL)
            let jsonObject = try JSONDecoder().decode(DefaultMappingsJSON.self, from: data)
            mappings = jsonObject.phonemePatterns.map { pattern in
                PhonemeVibePattern(
                    id: UUID(uuidString: pattern.id) ?? UUID(),
                    phoneme: pattern.phoneme,
                    pattern: pattern.pattern
                )
            }
        } catch {
            print("Failed to load default mappings: \(error)")
            // Create some basic mappings as a fallback
            createBasicMappings()
        }
    }
    
    private func createBasicMappings() {
        // Create some basic mappings for common phonemes
        // This is a fallback in case the JSON files can't be loaded
        let vowels = ["a", "e", "i", "o", "u", "ə", "æ", "ɑ", "ɛ", "ɪ", "ʊ", "ʌ"]
        let consonants = ["b", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "r", "s", "t", "v", "w", "z"]
        
        // Vowels get longer, smoother patterns
        for vowel in vowels {
            let pattern = VibePattern(intensity: 0.6, duration: 0.3, delay: 0.1)
            mappings.append(PhonemeVibePattern(phoneme: vowel, pattern: pattern))
        }
        
        // Consonants get shorter, sharper patterns
        for consonant in consonants {
            let pattern = VibePattern(intensity: 0.8, duration: 0.1, delay: 0.05)
            mappings.append(PhonemeVibePattern(phoneme: consonant, pattern: pattern))
        }
    }
    
    func saveUserMappings() {
        do {
            let data = try JSONEncoder().encode(mappings)
            try data.write(to: userMappingsURL)
        } catch {
            print("Failed to save user mappings: \(error)")
        }
    }
    
    func resetToDefaultMappings() {
        // Remove user mappings file if it exists
        if FileManager.default.fileExists(atPath: userMappingsURL.path) {
            do {
                try FileManager.default.removeItem(at: userMappingsURL)
            } catch {
                print("Failed to remove user mappings file: \(error)")
            }
        }
        
        // Reload default mappings
        loadMappings()
    }
    
    func getPattern(for phoneme: String) -> VibePattern? {
        return mappings.first(where: { $0.phoneme == phoneme })?.pattern
    }
    
    func updateMapping(for phoneme: String, with pattern: VibePattern) {
        if let index = mappings.firstIndex(where: { $0.phoneme == phoneme }) {
            mappings[index] = PhonemeVibePattern(id: mappings[index].id, phoneme: phoneme, pattern: pattern)
        } else {
            mappings.append(PhonemeVibePattern(phoneme: phoneme, pattern: pattern))
        }
        
        saveUserMappings()
    }
}