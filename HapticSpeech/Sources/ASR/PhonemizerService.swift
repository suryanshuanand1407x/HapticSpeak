//
//  PhonemizerService.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import Foundation
import Combine

class PhonemizerService: ObservableObject {
    // MARK: - Published Properties
    @Published var isProcessing = false
    @Published var phonemes: [String] = []
    @Published var errorMessage: String? = nil
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var selectedLanguage = "en" // Default to English
    
    // MARK: - Initialization
    init() {
        // Initialize any resources needed for phonemization
    }
    
    // MARK: - Public Methods
    
    /// Convert text to phonemes
    /// - Parameters:
    ///   - text: The text to convert to phonemes
    ///   - completion: Completion handler with Result<[String], Error>
    func textToPhonemes(_ text: String, completion: @escaping (Result<[String], Error>) -> Void) {
        guard !text.isEmpty else {
            phonemes = []
            completion(.success([]))
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        // In a real implementation, this would use a phonemizer library or API
        // For now, we'll simulate the phonemization with a simple mapping
        DispatchQueue.global().async { [weak self] in
            // Simulate processing time
            Thread.sleep(forTimeInterval: 0.5)
            
            // Simple phoneme mapping for demonstration
            let result = self?.simulatePhonemeConversion(text) ?? []
            
            DispatchQueue.main.async {
                self?.isProcessing = false
                self?.phonemes = result
                completion(.success(result))
            }
        }
    }
    
    /// Set the language for phonemization
    /// - Parameter languageCode: The ISO language code (e.g., "en", "fr")
    func setLanguage(_ languageCode: String) {
        selectedLanguage = languageCode
    }
    
    // MARK: - Private Methods
    
    /// Simulate phoneme conversion for demonstration purposes
    private func simulatePhonemeConversion(_ text: String) -> [String] {
        // This is a very simplified simulation of phoneme conversion
        // In a real app, you would use a proper phonemizer library
        
        // Convert text to lowercase and split into words
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        var result: [String] = []
        
        // Simple phoneme mapping for English
        let englishPhonemeMap: [Character: String] = [
            "a": "æ",
            "b": "b",
            "c": "k",
            "d": "d",
            "e": "ɛ",
            "f": "f",
            "g": "g",
            "h": "h",
            "i": "ɪ",
            "j": "dʒ",
            "k": "k",
            "l": "l",
            "m": "m",
            "n": "n",
            "o": "ɒ",
            "p": "p",
            "q": "kw",
            "r": "r",
            "s": "s",
            "t": "t",
            "u": "ʌ",
            "v": "v",
            "w": "w",
            "x": "ks",
            "y": "j",
            "z": "z"
        ]
        
        // Process each word
        for word in words {
            guard !word.isEmpty else { continue }
            
            var i = 0
            let chars = Array(word)
            
            while i < chars.count {
                // Check for digraphs (like "th")
                if i < chars.count - 1 && String(chars[i...i+1]) == "th" {
                    result.append("θ")
                    i += 2
                } else {
                    // Get phoneme for single character
                    if let phoneme = englishPhonemeMap[chars[i]] {
                        result.append(phoneme)
                    } else {
                        // If no mapping exists, use the character itself
                        result.append(String(chars[i]))
                    }
                    i += 1
                }
            }
            
            // Add a word boundary marker
            result.append("|") 
        }
        
        // Remove the last word boundary marker if it exists
        if let last = result.last, last == "|" {
            result.removeLast()
        }
        
        return result
    }
    
    /// Handle errors during processing
    private func handleError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.isProcessing = false
            self?.errorMessage = message
        }
    }
}