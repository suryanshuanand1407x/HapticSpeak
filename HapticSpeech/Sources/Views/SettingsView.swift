//
//  SettingsView.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bluetooth")) {
                    Toggle("Bluetooth Enabled", isOn: $viewModel.bluetoothEnabled)
                    
                    if viewModel.bluetoothEnabled {
                        Button(action: {
                            viewModel.startScanning()
                        }) {
                            Text("Scan for Devices")
                        }
                        
                        if viewModel.isScanning {
                            ProgressView("Scanning...")
                        }
                        
                        ForEach(viewModel.discoveredDevices, id: \.id) { device in
                            Button(action: {
                                viewModel.connectToDevice(device)
                            }) {
                                HStack {
                                    Text(device.name)
                                    Spacer()
                                    if viewModel.connectedDeviceID == device.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Haptic Feedback")) {
                    Slider(value: $viewModel.hapticIntensity, in: 0...1, step: 0.1) {
                        Text("Intensity")
                    }
                    Text("Intensity: \(Int(viewModel.hapticIntensity * 100))%")
                    
                    Picker("Haptic Pattern", selection: $viewModel.selectedPatternType) {
                        ForEach(viewModel.availablePatternTypes, id: \.self) { pattern in
                            Text(pattern).tag(pattern)
                        }
                    }
                    
                    Button(action: {
                        viewModel.testHapticPattern()
                    }) {
                        Text("Test Pattern")
                    }
                }
                
                Section(header: Text("Speech Recognition")) {
                    Toggle("Use On-Device Recognition", isOn: $viewModel.useOnDeviceRecognition)
                    
                    Picker("Language", selection: $viewModel.selectedLanguage) {
                        ForEach(viewModel.availableLanguages, id: \.code) { language in
                            Text(language.name).tag(language.code)
                        }
                    }
                }
                
                Section(header: Text("Advanced")) {
                    Button(action: {
                        viewModel.resetToDefaults()
                    }) {
                        Text("Reset to Defaults")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}