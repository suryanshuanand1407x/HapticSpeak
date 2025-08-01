//
//  HapticSpeechApp.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import SwiftUI

@main
struct HapticSpeechApp: App {
    // Initialize view models that need to persist throughout the app lifecycle
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(homeViewModel)
                .environmentObject(settingsViewModel)
        }
    }
}
