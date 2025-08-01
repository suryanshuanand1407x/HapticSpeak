//
//  SettingsViewModel.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import Foundation
import Combine

struct Language: Identifiable {
    let id = UUID()
    let name: String
    let code: String
}

struct BluetoothDevice: Identifiable {
    let id: String
    let name: String
}

class SettingsViewModel: ObservableObject {
    // Bluetooth settings
    @Published var bluetoothEnabled = false
    @Published var isScanning = false
    @Published var discoveredDevices: [BluetoothDevice] = []
    @Published var connectedDeviceID: String? = nil
    
    // Haptic feedback settings
    @Published var hapticIntensity: Double = 0.5
    @Published var selectedPatternType = "Standard"
    let availablePatternTypes = ["Standard", "Enhanced", "Subtle", "Custom"]
    
    // Speech recognition settings
    @Published var useOnDeviceRecognition = true
    @Published var selectedLanguage = "en-US"
    let availableLanguages = [
        Language(name: "English (US)", code: "en-US"),
        Language(name: "English (UK)", code: "en-GB"),
        Language(name: "Spanish", code: "es-ES"),
        Language(name: "French", code: "fr-FR"),
        Language(name: "German", code: "de-DE"),
        Language(name: "Japanese", code: "ja-JP"),
        Language(name: "Chinese (Simplified)", code: "zh-CN")
    ]
    
    // BLE Manager for device scanning and connection
    private let bleManager = BLEManager()
    
    // Haptic mapper for testing patterns
    private let hapticMapper = HapticMapper()
    
    // Cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
        loadSettings()
    }
    
    private func setupSubscriptions() {
        // Subscribe to BLE connection state changes
        bleManager.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                self.bluetoothEnabled = state != .disconnected
                
                if state == .connected, let peripheral = self.bleManager.connectedPeripheral {
                    self.connectedDeviceID = peripheral.id.uuidString
                } else {
                    self.connectedDeviceID = nil
                }
            }
            .store(in: &cancellables)
        
        // Subscribe to discovered devices
        bleManager.$discoveredPeripherals
            .receive(on: DispatchQueue.main)
            .map { peripherals in
                peripherals.map { peripheral in
                    BluetoothDevice(id: peripheral.id.uuidString, name: peripheral.name)
                }
            }
            .assign(to: &$discoveredDevices)
        
        // Subscribe to scanning state
        bleManager.$isScanning
            .receive(on: DispatchQueue.main)
            .assign(to: &$isScanning)
    }
    
    func startScanning() {
        bleManager.startScanning()
    }
    
    func connectToDevice(_ device: BluetoothDevice) {
        // Find the peripheral by ID and connect to it
        if let peripheral = bleManager.discoveredPeripherals.first(where: { $0.id.uuidString == device.id }) {
            bleManager.connect(to: peripheral)
        }
    }
    
    func testHapticPattern() {
        // Create a sample pattern based on the selected type
        let pattern: VibePattern
        
        switch selectedPatternType {
        case "Standard":
            pattern = VibePattern(intensity: Float(hapticIntensity), duration: 0.3, delay: 0.1)
        case "Enhanced":
            pattern = VibePattern(intensity: Float(hapticIntensity), duration: 0.5, delay: 0.05)
        case "Subtle":
            pattern = VibePattern(intensity: Float(hapticIntensity) * 0.7, duration: 0.2, delay: 0.2)
        case "Custom":
            pattern = VibePattern(intensity: Float(hapticIntensity), duration: 0.4, delay: 0.15)
        default:
            pattern = VibePattern(intensity: Float(hapticIntensity), duration: 0.3, delay: 0.1)
        }
        
        // Send the pattern to the connected device if available
        if bleManager.connectionState == .connected {
            bleManager.sendHapticPatterns([pattern])
        }
    }
    
    func resetToDefaults() {
        hapticIntensity = 0.5
        selectedPatternType = "Standard"
        useOnDeviceRecognition = true
        selectedLanguage = "en-US"
        
        saveSettings()
    }
    
    private func loadSettings() {
        // Load settings from UserDefaults
        let defaults = UserDefaults.standard
        hapticIntensity = defaults.double(forKey: "hapticIntensity")
        selectedPatternType = defaults.string(forKey: "selectedPatternType") ?? "Standard"
        useOnDeviceRecognition = defaults.bool(forKey: "useOnDeviceRecognition")
        selectedLanguage = defaults.string(forKey: "selectedLanguage") ?? "en-US"
    }
    
    private func saveSettings() {
        // Save settings to UserDefaults
        let defaults = UserDefaults.standard
        defaults.set(hapticIntensity, forKey: "hapticIntensity")
        defaults.set(selectedPatternType, forKey: "selectedPatternType")
        defaults.set(useOnDeviceRecognition, forKey: "useOnDeviceRecognition")
        defaults.set(selectedLanguage, forKey: "selectedLanguage")
    }
}