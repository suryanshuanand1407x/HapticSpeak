//
//  AnalyticsViewModel.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import Foundation
import Combine

struct PhonemeCount: Identifiable {
    let id = UUID()
    let phoneme: String
    let count: Int
}

class AnalyticsViewModel: ObservableObject {
    @Published var sessions: [SessionLog] = []
    @Published var topPhonemes: [PhonemeCount] = []
    @Published var formattedTotalRecordingTime: String = "0:00"
    @Published var formattedAverageSessionLength: String = "0:00"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSessions()
    }
    
    func refreshData() {
        loadSessions()
        calculateStatistics()
    }
    
    private func loadSessions() {
        // In a real app, this would load from persistent storage
        // For now, we'll create some sample data if none exists
        if sessions.isEmpty {
            createSampleData()
        }
    }
    
    private func createSampleData() {
        // This is just for demonstration purposes
        // In a real app, data would be collected during actual usage
        
        let sampleTexts = [
            "Hello, this is a test of the speech recognition system.",
            "The quick brown fox jumps over the lazy dog.",
            "How are you doing today? I hope you're having a great day!",
            "Speech to haptic feedback is an interesting technology.",
            "This app converts phonemes to vibration patterns."
        ]
        
        let samplePhonemes = [
            ["h", "ə", "l", "oʊ", "ð", "ɪ", "s", "ɪ", "z", "ə", "t", "ɛ", "s", "t"],
            ["ð", "ə", "k", "w", "ɪ", "k", "b", "r", "aʊ", "n", "f", "ɑ", "k", "s"],
            ["h", "aʊ", "ɑ", "r", "j", "u", "d", "u", "ɪ", "ŋ", "t", "ə", "d", "eɪ"],
            ["s", "p", "i", "tʃ", "t", "u", "h", "æ", "p", "t", "ɪ", "k", "f", "i", "d", "b", "æ", "k"],
            ["ð", "ɪ", "s", "æ", "p", "k", "ə", "n", "v", "ɝ", "t", "s", "f", "oʊ", "n", "i", "m", "z"]
        ]
        
        // Create sample sessions with random durations
        for i in 0..<5 {
            let duration = Double.random(in: 10...120) // 10 seconds to 2 minutes
            let timestamp = Date().addingTimeInterval(-Double.random(in: 0...86400)) // Within the last 24 hours
            
            let session = SessionLog(
                id: UUID(),
                timestamp: timestamp,
                duration: duration,
                recognizedText: sampleTexts[i],
                phonemes: samplePhonemes[i],
                hapticPatternsCount: Int.random(in: 10...30)
            )
            
            sessions.append(session)
        }
        
        // Sort sessions by timestamp (newest first)
        sessions.sort { $0.timestamp > $1.timestamp }
        
        calculateStatistics()
    }
    
    private func calculateStatistics() {
        // Calculate total recording time
        let totalSeconds = sessions.reduce(0) { $0 + $1.duration }
        formattedTotalRecordingTime = formatDuration(totalSeconds)
        
        // Calculate average session length
        if !sessions.isEmpty {
            let averageSeconds = totalSeconds / Double(sessions.count)
            formattedAverageSessionLength = formatDuration(averageSeconds)
        } else {
            formattedAverageSessionLength = "0:00"
        }
        
        // Calculate most common phonemes
        calculateTopPhonemes()
    }
    
    private func calculateTopPhonemes() {
        // Count occurrences of each phoneme across all sessions
        var phonemeCounts: [String: Int] = [:]
        
        for session in sessions {
            for phoneme in session.phonemes {
                phonemeCounts[phoneme, default: 0] += 1
            }
        }
        
        // Convert to array and sort by count (descending)
        let sortedPhonemes = phonemeCounts.map { PhonemeCount(phoneme: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
        
        // Take top 10 phonemes
        topPhonemes = Array(sortedPhonemes.prefix(10))
    }
    
    private func formatDuration(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return "\(minutes):\(String(format: "%02d", remainingSeconds))"
    }
    
    func exportData() {
        // In a real app, this would export session data to a file
        // For now, we'll just print to the console
        print("Exporting \(sessions.count) sessions...")
    }
}