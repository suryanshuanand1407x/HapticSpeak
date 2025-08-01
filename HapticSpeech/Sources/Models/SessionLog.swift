//
//  SessionLog.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import Foundation

struct SessionLog: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let duration: Double // in seconds
    let recognizedText: String
    let phonemes: [String]
    let hapticPatternsCount: Int
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

extension SessionLog {
    static func save(_ sessions: [SessionLog]) {
        do {
            let data = try JSONEncoder().encode(sessions)
            try data.write(to: getFileURL())
        } catch {
            print("Failed to save sessions: \(error)")
        }
    }
    
    static func load() -> [SessionLog] {
        do {
            let data = try Data(contentsOf: getFileURL())
            return try JSONDecoder().decode([SessionLog].self, from: data)
        } catch {
            print("Failed to load sessions: \(error)")
            return []
        }
    }
    
    static func getFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("sessions.json")
    }
    
    static func addSession(_ session: SessionLog) {
        var sessions = load()
        sessions.append(session)
        save(sessions)
    }
}