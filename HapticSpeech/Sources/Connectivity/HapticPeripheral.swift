//
//  HapticPeripheral.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import Foundation
import CoreBluetooth

class HapticPeripheral: Identifiable, ObservableObject {
    // MARK: - Properties
    let id: UUID
    let peripheral: CBPeripheral
    @Published var rssi: Int
    @Published var isConnected: Bool = false
    
    // Characteristic for sending haptic patterns
    var hapticCharacteristic: CBCharacteristic?
    
    // MARK: - Initialization
    init(peripheral: CBPeripheral, rssi: Int) {
        self.id = peripheral.identifier
        self.peripheral = peripheral
        self.rssi = rssi
    }
    
    // MARK: - Public Methods
    
    // Send a vibration pattern to the peripheral
    func sendVibePattern(_ data: Data) {
        guard let characteristic = hapticCharacteristic else {
            print("Haptic characteristic not found")
            return
        }
        
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    // Get the name of the peripheral
    var name: String {
        return peripheral.name ?? "Unknown Device"
    }
    
    // Get the signal strength as a string
    var signalStrengthDescription: String {
        if rssi >= -50 {
            return "Excellent"
        } else if rssi >= -70 {
            return "Good"
        } else if rssi >= -90 {
            return "Fair"
        } else {
            return "Poor"
        }
    }
    
    // Get the signal strength as a percentage (0-100)
    var signalStrengthPercentage: Int {
        // RSSI typically ranges from -100 (weak) to -30 (strong)
        // Convert to a percentage where -30 is 100% and -100 is 0%
        let percentage = min(100, max(0, (rssi + 100) * 100 / 70))
        return percentage
    }
    
    // Update the RSSI value
    func updateRSSI(_ newRSSI: Int) {
        rssi = newRSSI
    }
    
    // Update the connection status
    func updateConnectionStatus(isConnected: Bool) {
        self.isConnected = isConnected
    }
}

// MARK: - Equatable
extension HapticPeripheral: Equatable {
    static func == (lhs: HapticPeripheral, rhs: HapticPeripheral) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension HapticPeripheral: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}