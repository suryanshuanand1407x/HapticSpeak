# HapticSpeech

HapticSpeech is an iOS application that converts speech to haptic feedback patterns, making spoken language accessible through vibration patterns.

## Project Structure

```
HapticSpeech/
 ├── Sources/
 │   ├── AudioEngine/           // Audio capture & buffering
 │   │   ├── AudioBufferManager.swift
 │   │   └── AudioSessionManager.swift
 │   ├── ASR/                   // Automatic Speech Recognition
 │   │   ├── WhisperService.swift
 │   │   └── PhonemizerService.swift
 │   ├── Haptics/               // Vibration mapping
 │   │   ├── HapticMapper.swift
 │   │   └── VibePattern.swift
 │   ├── Connectivity/          // BLE central role
 │   │   ├── BLEManager.swift
 │   │   └── HapticPeripheral.swift
 │   ├── Models/                // Data models & logging
 │   │   ├── SessionLog.swift
 │   │   └── PhonemeVibePattern.swift
 │   ├── Views/                 // SwiftUI screens
 │   │   ├── HomeView.swift
 │   │   ├── SettingsView.swift
 │   │   └── AnalyticsView.swift
 │   └── ViewModels/            // MVVM glue
 │       ├── HomeViewModel.swift
 │       ├── SettingsViewModel.swift
 │       └── AnalyticsViewModel.swift
 └── Resources/
     ├── Models/                // .mlmodel files
     └── DefaultMappings.json
```

## Features

- **Speech Recognition**: Captures audio and converts it to text using Whisper ASR.
- **Phoneme Extraction**: Converts recognized text into phonemes.
- **Haptic Mapping**: Maps phonemes to vibration patterns.
- **Bluetooth Connectivity**: Sends vibration patterns to connected haptic devices.
- **Analytics**: Tracks usage statistics and session history.
- **Settings**: Customizable haptic feedback and speech recognition options.

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Getting Started

1. Clone the repository
2. Open `HapticSpeech.xcodeproj` in Xcode
3. Build and run the application on your iOS device

## Architecture

The application follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures and business logic
- **Views**: SwiftUI user interface components
- **ViewModels**: Intermediary between Models and Views, handling UI logic

## License

This project is licensed under the MIT License - see the LICENSE file for details.