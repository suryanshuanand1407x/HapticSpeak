# HapticSpeech Application Analysis

**HapticSpeech** is an iOS accessibility application that converts speech to haptic feedback patterns, making spoken language accessible through vibration patterns for deaf and hard-of-hearing users.

## **Core Functionality**
1. **Speech Recognition**: Captures audio through the microphone and converts it to text using Whisper ASR (Automatic Speech Recognition)
2. **Phoneme Extraction**: Converts recognized text into individual phonemes using a phonemizer service
3. **Haptic Mapping**: Maps each phoneme to unique vibration patterns with specific intensity, duration, and delay characteristics
4. **Bluetooth Transmission**: Sends haptic patterns to connected BLE (Bluetooth Low Energy) devices for external haptic feedback
5. **Session Logging**: Tracks usage statistics and session history for analytics

## **Architecture & Components**

**Technology Stack**: iOS (Swift 5.0+, iOS 18.1+), SwiftUI, Core Haptics, Core Bluetooth, AVFoundation

**Key Components**:
- **AudioEngine**: `AudioSessionManager.swift:13`, `AudioBufferManager.swift:14` - Audio capture and buffering
- **ASR**: `WhisperService.swift:12`, `PhonemizerService.swift:18` - Speech-to-text and phoneme extraction  
- **Haptics**: `HapticMapper.swift:11`, `VibePattern.swift` - Vibration pattern generation and mapping
- **Connectivity**: `BLEManager.swift:12`, `HapticPeripheral.swift` - Bluetooth device communication
- **UI**: `HomeView.swift:10`, `SettingsView.swift`, `AnalyticsView.swift` - SwiftUI interface components

## **Phoneme-to-Haptic Mapping**
The application uses a comprehensive phoneme mapping system (`DefaultMappings.json:1`) with 34 different phoneme patterns, each defined by:
- **Intensity**: Vibration strength (0.0-1.0)
- **Duration**: Pattern length in seconds
- **Delay**: Gap before next pattern

Example mappings include vowels (æ, ɑ, ɛ), consonants (b, d, f), and special characters like silence (|).

## **User Flow**
1. User taps "Start Recording" in `HomeView.swift:27`
2. Audio captured via `HomeViewModel.swift:63`
3. Speech processed by `WhisperService.swift:34`
4. Text converted to phonemes by `PhonemizerService.swift:106`
5. Phonemes mapped to haptic patterns by `HapticMapper.swift:127`
6. Patterns sent to connected BLE devices or played locally
7. Session logged for analytics in `SessionLog.swift:139`

This application serves as an innovative accessibility tool, bridging auditory communication gaps through tactile feedback technology.